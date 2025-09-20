terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.14.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "eu-north-1"
}

locals {
  project = "project-01"
}

resource "aws_vpc" "my-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "${local.project}-vpc"
  }
}


resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = "10.0.${count.index}.0/24"
  count      = 2
  tags = {
    Name = "${local.project}-subnet-${count.index}"
  }
}

# Creating 4 EC2 Instance
# resource "aws_instance" "main" {
#   ami           = "ami-0a716d3f3b16d290c"
#   instance_type = "t3.micro"
#   count         = 4
#   subnet_id     = element(aws_subnet.main[*].id, count.index % length(aws_instance.main))

#   tags = {
#     Name = "${local.project}-instance-${count.index}"
#   }
# }


# Creating 2 EC2 Instance
# resource "aws_instance" "main" {
#   count         = length(var.ec2_config)
#   ami           = var.ec2_config[count.index].ami
#   instance_type = var.ec2_config[count.index].instance_type

#   subnet_id = element(aws_subnet.main[*].id, count.index % length(aws_subnet.main))

#   tags = {
#     Name = "${local.project}-instance-${count.index}"
#   }
# }

resource "aws_instance" "main" {

  # We will get each.key & each.value
  for_each = var.ec2_map

  ami           = each.value.ami
  instance_type = each.value.instance_type

  subnet_id = element(aws_subnet.main[*].id, index(keys(var.ec2_map), each.key) % length(aws_subnet.main))

  tags = {
    Name = "${local.project}-instance-${each.key}"
  }
}

output "aws_subnet_id" {
  value = aws_subnet.main[1].id
}





