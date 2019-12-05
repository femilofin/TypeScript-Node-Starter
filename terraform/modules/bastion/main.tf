data "aws_ami" "stable_coreos" {
  most_recent = true

  filter {
    name   = "description"
    values = ["CoreOS stable *"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["595879546273"] # CoreOS
}

resource "aws_security_group" "bastion" {
  name        = "bastion-${var.environment}"
  description = "${var.environment} Bastion SG"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "allow_all_in" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.bastion.id
}

resource "aws_security_group_rule" "allow_all_out" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.bastion.id
}

resource "aws_launch_configuration" "lc" {
  name_prefix                 = "bastion-${var.environment}-"
  image_id                    = data.aws_ami.stable_coreos.id
  instance_type               = "t2.nano"
  key_name                    = var.environment
  associate_public_ip_address = true
  security_groups             = [aws_security_group.bastion.id]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {
  availability_zones        = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  name                      = "bastion-${var.environment}"
  desired_capacity          = 1
  min_size                  = 1
  max_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "EC2"

  vpc_zone_identifier = flatten([var.public_subnets])
  launch_configuration = aws_launch_configuration.lc.name

  termination_policies = ["OldestInstance"]

  lifecycle {
    create_before_destroy = true
  }
}

output "bastion_sg_id" {
  value = aws_security_group.bastion.id
}
