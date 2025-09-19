
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
  region = var.region
}

resource "aws_instance" "my-server" {
  ami           = "ami-043339ea831b48099"
  instance_type = "t3.nano"

  tags = {
    Name = "SampleServer"
  }
}


