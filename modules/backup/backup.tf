# resource "aws_backup_vault" "default" {
#   name = "default-backup-vault"
# }

# resource "aws_backup_plan" "daily_backup" {
#   name = "daily-backup-plan"

#   rule {
#     rule_name         = "daily-backup-rule"
#     target_vault_name = aws_backup_vault.default.name
#     schedule          = "cron(0 12 * * ? *)" # Daily at 12 PM UTC

#     lifecycle {
#       delete_after       = 97  # 7 + 90
#       cold_storage_after = 7 # Move to cold storage after 7 days
#     }
#   }
# }

# resource "aws_backup_selection" "backup_resources" {
#   name         = "s3-backup-selection" # Add a descriptive name
#   iam_role_arn = aws_iam_role.backup_role.arn
#   plan_id      = aws_backup_plan.daily_backup.id

#   selection_tag {
#     type  = "STRINGEQUALS"
#     key   = "name"
#     value = "S3"
#   }
# }


# resource "aws_iam_role" "backup_role" {
#   name = "backup-role"

#   assume_role_policy = jsonencode(
#     {
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           Service = "backup.amazonaws.com"
#         }
#       },
#     ]
#   })
# }

# resource "aws_iam_role_policy" "backup_role_policy" {
#   name = "backup-policy"
#   role = aws_iam_role.backup_role.name

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         Action = [
#           "backup:StartBackupJob",
#           "backup:ListBackupJobs",
#           "backup:GetBackupVaultAccessPolicy",
#           "backup:ListBackupVaults",
#           "backup:ListRecoveryPointsByBackupVault",
#           "s3:GetBucketTagging",
#           "s3:ListAllMyBuckets",
#           "tag:GetResources"
#         ],
#         Resource = "*"
#       },
#       {
#         Effect = "Allow",
#         Action = [
#           "ec2:DescribeInstances",
#           "rds:DescribeDBInstances",
#           "dynamodb:DescribeTable",
#           "dynamodb:ListTables"
#         ],
#         Resource = "*"
#       }
#     ]
#   })
# }
