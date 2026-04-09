terraform {
  required_version = "~> 1.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.27"
    }
  }

  # Recommended: enable S3 backend for shared/team state management.
  # Steps:
  #   1. Create an S3 bucket and DynamoDB table for state locking.
  #   2. Uncomment the block below and fill in your values.
  #   3. Run `terraform init -migrate-state` to migrate local state.
  #
  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "agrox/terraform.tfstate"
  #   region         = "ap-south-1"
  #   dynamodb_table = "terraform-state-lock"
  #   encrypt        = true
  # }
}

provider "aws" {
  region = var.aws_region
}
