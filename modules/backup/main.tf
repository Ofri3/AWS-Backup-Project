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

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "backup_role" {
  name               = var.role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "policy" {
  statement {
    effect    = "Allow"
    actions   = ["backup:Describe*"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "role_policy_name" {
  name        = var.role_policy_name
  description = "A test policy"
  policy      = data.aws_iam_policy_document.policy.json
}

resource "aws_iam_role_policy_attachment" "policy-attach" {
  role       = var.role_name
  policy_arn = var.role_policy_arn
}