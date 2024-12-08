variable "region" {
  description = "AWS region to deploy resources"
  type        = string
}

variable "backup_bucket_name" {
  description = "Name of the S3 bucket for backups"
  type        = string
}

variable "ec2_instance_id" {
  description = "The ID of the EC2 instance to back up"
  type        = string
}

variable "rds_instance_id" {
  description = "The ID of the RDS instance to back up"
  type        = string
}
