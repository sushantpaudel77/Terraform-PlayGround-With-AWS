provider "aws" {
  region = "eu-north-1"
}

module "vpc" {
  source = "./module/vpc"

  vpc_config = {
    cidr_block = "10.0.0.0/16"
    name       = "my-test-vpc"
  }

  subnet_config = {
    # Key = {cidr, azs}
    public_subnets-1 = {
      cidr_block = "10.0.0.0/24"
      azs        = "eu-north-1a"
      public     = true
    }

    public_subnets-2 = {
      cidr_block = "10.0.2.0/24"
      azs        = "eu-north-1a"
      public     = true
    }

    private_subnets = {
      cidr_block = "10.0.1.0/24"
      azs        = "eu-north-1b"
    }
  }
}
