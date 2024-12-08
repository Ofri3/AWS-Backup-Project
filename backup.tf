resource "aws_backup_vault" "default" {
  name = "default-backup-vault"
}

resource "aws_backup_plan" "daily_backup" {
  name = "daily-backup-plan"

  rule {
    rule_name         = "daily-backup-rule"
    target_vault_name = aws_backup_vault.default.name
    schedule          = "cron(0 12 * * ? *)"  # Daily at 12 PM UTC

    lifecycle {
      delete_after        = 30
      cold_storage_after  = 7  # Move to cold storage after 7 days
    }
  }
}

resource "aws_backup_selection" "backup_resources" {
  iam_role_arn = aws_iam_role.backup_role.arn
  plan_id      = aws_backup_plan.daily_backup.id

  resources = concat(
    module.s3_backup.resources,
    module.rds_backup.resources,
    module.ec2_backup.resources
  )
}
