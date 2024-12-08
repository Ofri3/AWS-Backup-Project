resource "aws_s3_bucket" "backup_bucket" {
  bucket = var.backup_bucket_name
  acl    = "private"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    id      = "expire_backups"
    enabled = true
    expiration {
      days = 30
    }
  }
}
