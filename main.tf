terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

module "s3" {
  source = "./modules/s3"
  bucket_name = var.backup_bucket_name
}

module "rds" {
  source = "./modules/rds"
  rds_instance_id = var.rds_instance_id
}

module "ec2" {
  source = "./modules/ec2"
  ec2_instance_id = var.ec2_instance_id
}
