variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = set(string)
}

variable "source_security_group_id" {
  type = string
}

resource aws_efs_file_system "efs" {
}

resource aws_security_group "efs_security_group" {
  name   = "efs-sg"
  vpc_id = var.vpc_id
}

resource aws_security_group_rule efs_ingress_security_group_rule {
  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  source_security_group_id = var.source_security_group_id
  security_group_id        = aws_security_group.efs_security_group.id
}

resource aws_security_group_rule efs_egress_security_group_rule {
  type                     = "egress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  source_security_group_id = var.source_security_group_id
  security_group_id        = aws_security_group.efs_security_group.id
}

resource aws_efs_mount_target "az_1_mt" {
  for_each = var.subnet_ids

  file_system_id = aws_efs_file_system.efs.id
  subnet_id      = each.value
  security_groups = [aws_security_group.efs_security_group.id]
}

output "efs_id" {
  value = aws_efs_file_system.efs.id
}