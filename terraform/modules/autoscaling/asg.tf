provider "ignition" {
  version = "1.2.0"
}

// Get AMI
data "aws_ami" "stable_coreos" {
  most_recent = true

  filter {
    name   = "description"
    values = ["CoreOS Container Linux stable*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["679593333241"] # CoreOS
}

# ECS agent
data "template_file" "ecs" {
  template = file("${path.module}/files/ecs.tpl")

  vars = {
    cluster_name = var.cluster_name
  }
}

data "ignition_systemd_unit" "ecs" {
  name    = "amazon-ecs-agent.service"
  content = data.template_file.ecs.rendered
}

data "ignition_systemd_unit" "rpc" {
  name = "rpc-statd.service"
}

data "ignition_config" "cloud_config" {
  systemd = [
    data.ignition_systemd_unit.ecs.rendered,
    data.ignition_systemd_unit.rpc.rendered,
  ]
}

resource "aws_security_group_rule" "allow_all_out_from_ecs" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.internal.id
}

resource "aws_launch_configuration" "lc" {
  name_prefix                 = "${var.cluster_name}-"
  image_id                    = data.aws_ami.stable_coreos.id
  instance_type               = var.instance_type
  iam_instance_profile        = aws_iam_instance_profile.ecs_service.name
  key_name                    = var.environment
  user_data                   = data.ignition_config.cloud_config.rendered
  associate_public_ip_address = false
  security_groups             = [aws_security_group.internal.id]

  root_block_device {
    volume_size = var.root_ebs_size
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {
  availability_zones        = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  name                      = var.cluster_name
  desired_capacity          = var.desired_capacity
  min_size                  = var.desired_capacity
  max_size                  = var.max_size
  health_check_grace_period = 120
  health_check_type         = "EC2"
  vpc_zone_identifier       = var.private_subnets
  launch_configuration      = aws_launch_configuration.lc.name

  termination_policies = ["OldestInstance"]

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = var.cluster_name
    propagate_at_launch = true
  }
}
