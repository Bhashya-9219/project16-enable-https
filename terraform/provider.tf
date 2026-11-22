terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"

  default_tags {
    tags = {
      Owner       = "MB"
      Project     = "Project-16"
      Environment = "Learning"
      ManagedBy   = "Terraform"
    }
  }
}
