terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket         = "solid-bucket-123"
    key            = "solid-bucket-123/terraform.tfstate"
    region         = "ap-southeast-2"
    dynamodb_table = "terraform-lock2"
  }
}

provider "aws" {
  region = "ap-southeast-2"
}

