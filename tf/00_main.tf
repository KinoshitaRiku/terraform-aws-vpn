terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "local" {}
}

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      env        = var.env
      repogitory = "terraform-aws-vpn"
    }
  }
}

data "aws_caller_identity" "current" {}
