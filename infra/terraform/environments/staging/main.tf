terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Project     = "devops-sre-challenge"
      Environment = "staging"
      ManagedBy   = "Terraform"
    }
  }
}

module "infrastructure" {
  source = "../../"

  aws_region   = "us-east-1"
  project_name = "devops-sre-challenge"
  environment  = "staging"

  vpc_cidr           = "10.1.0.0/16"
  kubernetes_version = "1.30"

  repository_owner  = "gisellebc"
  repository_name   = "devops-sre-challenge"
  repository_branch = "staging"

  connection_arn = "arn:aws:codeconnections:us-east-1:000000000000:connection/00000000-0000-0000-0000-000000000000"
}