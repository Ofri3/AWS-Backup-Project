resource "aws_db_snapshot" "rds_backup" {
  db_instance_identifier = var.rds_instance_id
  db_snapshot_identifier = "rds-backup-${timestamp()}"
}