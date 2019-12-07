resource "aws_security_group" "lb_sg" {
  description = "controls access to the application ALB"

  vpc_id = var.vpc_id
  name   = "${var.cluster_name}-alb"

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  tags = {
    Name = var.cluster_name
  }
}

resource "aws_security_group_rule" "elb" {
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "32768"
  to_port                  = "60999"
  security_group_id        = module.autoscaling.internal_sg_id
  source_security_group_id = aws_security_group.lb_sg.id
}

resource "aws_alb" "alb" {
  internal        = false
  name            = var.cluster_name
  subnets         = var.public_subnets
  security_groups = [aws_security_group.lb_sg.id]

  enable_deletion_protection = false

  tags = {
    key  = "stack"
    name = var.cluster_name
  }
}

resource "aws_alb_target_group" "default" {
  name     = "default-${var.environment}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_alb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.default.id
    type             = "forward"
  }
}

resource "aws_alb_listener" "https" {
  load_balancer_arn = aws_alb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2015-05"
  certificate_arn   = var.certificate_arn

  default_action {
    target_group_arn = aws_alb_target_group.default.id
    type             = "forward"
  }
}

output "alb_dns_name" {
  value = aws_alb.alb.dns_name
}

output "alb_zone_id" {
  value = aws_alb.alb.zone_id
}

output "http_listener_arn" {
  value = aws_alb_listener.http.arn
}

output "https_listener_arn" {
  value = aws_alb_listener.https.arn
}
