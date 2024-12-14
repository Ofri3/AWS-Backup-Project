# Terraform Module for AWS Backup Setup

## Usage

This Terraform module creates an AWS Backup setup with a daily backup plan, backup vault, IAM role, and policy for managing backups. It supports S3 resource backups using tags.

### Inputs
- `backup_vault_name`: The name of the backup vault. Default: `default-backup-vault`
- `backup_plan_name`: The name of the backup plan. Default: `daily-backup-plan`
- `backup_rule_name`: The name of the backup rule. Default: `daily-backup-rule`
- `schedule`: The schedule in cron expression for backups. Default: `cron(0 12 * * ? *)`
- `delete_after`: Number of days after which backups are deleted. Default: `97`
- `cold_storage_after`: Number of days after which backups are moved to cold storage. Default: `7`
- `selection_name`: The name for resource selection. Default: `s3-backup-selection`
- `tag_key`: The key for resource tagging. Default: `name`
- `tag_value`: The value for resource tagging. Default: `S3`
- `role_name`: The name of the IAM role for backups. Default: `backup-role`
- `role_policy_name`: The name of the IAM role policy. Default: `backup-policy`

```hcl
module "aws_backup" {
  source            = "./modules/aws_backup"
  backup_vault_name = "my-backup-vault"
  backup_plan_name  = "my-backup-plan"
  backup_rule_name  = "my-backup-rule"
  schedule          = "cron(0 18 * * ? *)" # Daily at 6 PM UTC
  delete_after      = 30
  cold_storage_after = 5
  selection_name    = "my-backup-selection"
  tag_key           = "environment"
  tag_value         = "production"
  role_name         = "my-backup-role"
  role_policy_name  = "my-backup-role-policy"
}
```

## Outputs
- `backup_vault_id`: The ID of the backup vault.
- `backup_plan_id`: The ID of the backup plan.
- `iam_role_arn`: The ARN of the IAM role created for backup.

## Module Structure
```hcl
variable "backup_vault_name" {
  default = "default-backup-vault"
}

resource "aws_backup_vault" "this" {
  name = var.backup_vault_name
}

variable "role_policy"
