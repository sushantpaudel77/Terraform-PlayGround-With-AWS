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
  owner = "ABC"
  name = "MYSERVER"
}

resource "aws_instance" "my-server" {
  ami           = "ami-043339ea831b48099"
  instance_type = var.aws_instance_type

  root_block_device {
    delete_on_termination = true
    volume_size           = var.ec2_config.v_size
    volume_type           = var.ec2_config.v_type
  }

  tags = merge(var.additional_tags, {
    Name = local.name
  })
}
