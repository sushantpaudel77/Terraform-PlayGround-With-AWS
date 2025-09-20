# -----------------------------
# Terraform & AWS Provider Setup
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.14.0" # Specify AWS provider version
    }
  }
}

provider "aws" {
  region = "eu-north-1" # AWS region for all resources
}

# Locals - Loading Users from YAML
locals {
  # Read users.yaml file and parse it as a list of user objects
  users_data = yamldecode(file("./users.yaml")).users

  # Create a flattened list of username-role pairs
  # Example output:
  # [
  #   { username = "alice", role = "Admin" },
  #   { username = "alice", role = "Developer" },
  #   { username = "bob", role = "Developer" }
  # ]
  user_role_pair = flatten([
    for user in local.users_data : [
      for role in user.roles : {
        username = user.username
        role     = role
      }
    ]
  ])
}

# Output for Debugging
output "output" {
  value = local.user_role_pair # Print flattened username-role list
}

# IAM User Creation
resource "aws_iam_user" "users" {
  # Create one IAM user for each username in users_data
  for_each = toset(local.users_data[*].username)
  name     = each.value
}


# IAM User Password/Login Profile
resource "aws_iam_user_login_profile" "profile" {
  # Create a login profile for each IAM user
  for_each        = aws_iam_user.users
  user            = each.value.name
  password_length = 12 # Terraform will auto-generate a 12-char password

  lifecycle {
    # Ignore changes for certain fields to prevent unnecessary diffs in state
    ignore_changes = [
      password_length,
      password_reset_required,
      pgp_key,
    ]
  }
}


# Attach IAM Policies to Users
resource "aws_iam_user_policy_attachment" "main" {
  # Use a map with unique keys for each username-role pair
  # For Instance: # bob-AmazonEC2FullAccess = {username = bob, role = AmazonEC2FullAccess}
  for_each = {
    for pair in local.user_role_pair :
    "${pair.username}-${pair.role}" => pair
  }

  # Attach policy to user
  user = aws_iam_user.users[each.value.username].name
  # Use AWS managed policy ARN dynamically
  policy_arn = "arn:aws:iam::aws:policy/${each.value.role}"
}
