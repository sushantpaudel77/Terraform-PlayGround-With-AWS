terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.14.0"
    }
  }
  backend "s3" {
    bucket = "demo-bucket-a18420669a71cc4e"
    key = "backend.tfstate"
    region = "eu-north-1"
  }
}

provider "aws" {
  # Configuration options
  region = "eu-north-1"
}

resource "aws_instance" "my-server" {
  ami           = "ami-043339ea831b48099"
  instance_type = "t3.nano"

  tags = {
    Name = "SampleServer"
  }
}


