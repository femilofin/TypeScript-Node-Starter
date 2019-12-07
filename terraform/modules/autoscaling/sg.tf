resource "aws_security_group" "internal" {
  name        = "${var.cluster_name}-internal"
  description = "${var.cluster_name} internal SG"

  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "bastion" {
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 22
  to_port                  = 22
  security_group_id        = aws_security_group.internal.id
  source_security_group_id = var.bastion_sg_id
}

resource "aws_security_group_rule" "redis" {
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 6379
  to_port                  = 6379
  security_group_id        = aws_security_group.internal.id
  source_security_group_id = aws_security_group.internal.id
}

output "internal_sg_id" {
  value = aws_security_group.internal.id
}
