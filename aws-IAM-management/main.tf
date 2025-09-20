# Terraform & AWS Provider Setup
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.14.0"
    }
  }
}

provider "aws" {
  region = "eu-north-1"
}

locals {
  users_data = yamldecode(file("./users.yaml")).users

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
  value = local.user_role_pair
}

# IAM User Creation
resource "aws_iam_user" "users" {
  for_each      = toset(local.users_data[*].username)
  name          = each.value
  force_destroy = true

  tags = {
    ManagedBy = "Terraform"
  }
}

# IAM User Password/Login Profile
resource "aws_iam_user_login_profile" "profile" {
  for_each        = aws_iam_user.users
  user            = each.value.name
  password_length = 12

  lifecycle {
    ignore_changes = [
      password_length,
      password_reset_required,
      pgp_key,
    ]
  }

  depends_on = [aws_iam_user.users]
}

# Attach IAM Policies to Users
resource "aws_iam_user_policy_attachment" "main" {
  for_each = {
    for pair in local.user_role_pair :
    "${pair.username}-${pair.role}" => pair
  }

  user       = aws_iam_user.users[each.value.username].name
  policy_arn = "arn:aws:iam::aws:policy/${each.value.role}"

  # Explicit lifecycle management for proper destruction
  lifecycle {
    create_before_destroy = false
  }

  depends_on = [
    aws_iam_user.users,
    aws_iam_user_login_profile.profile
  ]
}

# Alternative approach: Use data source to verify policy exists
data "aws_iam_policy" "managed_policies" {
  for_each = toset([for pair in local.user_role_pair : pair.role])
  arn      = "arn:aws:iam::aws:policy/${each.value}"
}