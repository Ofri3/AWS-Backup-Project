resource "aws_backup_vault" "default" {
  name = var.backup_vault_name
}

resource "aws_backup_plan" "daily_backup" {
  name = var.backup_plan_name

  rule {
    rule_name         = var.backup_rule_name
    target_vault_name = aws_backup_vault.default.name
    schedule          = var.schedule

    lifecycle {
      delete_after       = var.delete_after
      cold_storage_after = var.cold_storage_after
    }
  }
}

resource "aws_backup_selection" "backup_resources" {
  name         = var.selection_name
  iam_role_arn = aws_iam_role.backup_role.arn
  plan_id      = aws_backup_plan.daily_backup.id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = var.tag_key
    value = var.tag_value
  }
}

resource "aws_iam_role" "backup_role" {
  name = var.role_name

  assume_role_policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "backup.amazonaws.com"
          }
        },
      ]
    }
  )
}

resource "aws_iam_role_policy" "backup_role_policy" {
  name = var.role_policy_name
  role = aws_iam_role.backup_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "backup:StartBackupJob",
          "backup:ListBackupJobs",
          "backup:GetBackupVaultAccessPolicy",
          "backup:ListBackupVaults",
          "backup:ListRecoveryPointsByBackupVault",
          "s3:GetBucketTagging",
          "s3:ListAllMyBuckets",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:PutObject",
          "s3:DeleteObject",
          "tag:GetResources"
        ],
        Resource = [
          "arn:aws:s3:::eks-velero-backup-bucket",
          "arn:aws:s3:::eks-velero-backup-bucket/*",
          "arn:aws:s3:::terraform-state-ofri",
          "arn:aws:s3:::terraform-state-ofri/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "ec2:DescribeInstances",
          "rds:DescribeDBInstances",
          "dynamodb:DescribeTable",
          "dynamodb:ListTables"
        ],
        Resource = "*"
      }
    ]
  })
}
