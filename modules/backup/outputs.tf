output "backup_vault_id" {
  description = "The ID of the backup vault."
  value       = aws_backup_vault.default.id
}

output "backup_plan_id" {
  description = "The ID of the backup plan."
  value       = aws_backup_plan.daily_backup.id
}

output "iam_role_arn" {
  description = "The ARN of the IAM role created for backup."
  value       = aws_iam_role.backup_role.arn
}