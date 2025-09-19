terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.14.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "eu-north-1"
}

data "aws_ami" "name" {
  most_recent = true
  owners = [ "amazon" ]
}

output "aws_ami" {
  value = data.aws_ami.name.id
}

# Securty group
data "aws_security_group" "name" {
  tags = {
    mywebserver = "http"
  }
}

output "security_group" {
  value = data.aws_security_group.name.id
}

# VPC
data "aws_vpc" "name" {
  tags = {
    ENV = "PROD"
    Name = "my-vpc"
  }
}

output "vpc_id" {
  value = data.aws_vpc.name.id
}

# AZ
data "aws_availability_zones" "names" {
  state = "available"
}

output "aws_zones" {
  value = data.aws_availability_zones.names
}

# To get the account details
data "aws_caller_identity" "name" {
  
}

output "caller_info" {
  value = data.aws_caller_identity.name
}

# To get the region
data "aws_region" "name" {
  
}

output "region_name" {
  value = data.aws_region.name
}

resource "aws_instance" "my-server" {
  ami           = "data.aws_ami.name.id"
  instance_type = "t3.nano"

  tags = {
    Name = "SampleServer"
  }
}