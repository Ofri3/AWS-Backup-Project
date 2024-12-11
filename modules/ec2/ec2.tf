resource "aws_ebs_snapshot" "ec2_backup" {
  volume_id = data.aws_ebs_volume.ec2_volume.id
  tags = {
    Name = "EC2 Backup Snapshot"
  }
}

data "aws_ebs_volume" "ec2_volume" {
  filter {
    name   = "attachment.instance-id"
    values = [var.ec2_instance_id]
  }
}