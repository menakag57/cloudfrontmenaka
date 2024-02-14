# Terraform Block
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
  # Adding Backend as S3 for Remote State Storage
  backend "s3" {
    bucket = "cloudfrontbackend"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}

# Provider Block

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

