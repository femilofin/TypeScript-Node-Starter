resource "aws_ecr_repository" "repository" {
  name = "${var.project}-${var.app}-${var.environment}"
}

resource "aws_ecr_repository" "repository_nginx" {
  name = "${var.project}-${var.app}-nginx-${var.environment}"
}

data "aws_route53_zone" "domain" {
  name = "${var.domain}."
}

resource "aws_route53_record" "record" {
  zone_id = data.aws_route53_zone.domain.zone_id
  name    = "${var.url}.${var.domain}"
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}

resource "aws_alb_target_group" "target" {
  name     = "${var.project}-${var.app}-${var.environment}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path    = var.health_check
    matcher = "200,301"
  }
}

resource "aws_cloudwatch_log_group" "log" {
  name = var.cluster_name

  tags = {
    Environment = var.environment
    Application = "${var.app}-service"
  }
}

resource "aws_alb_listener_rule" "http_rule" {
  listener_arn = var.http_listener_arn
  priority     = var.http_rule_priority

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.target.arn
  }

  condition {
    field  = "host-header"
    values = ["${var.url}.${var.domain}"]
  }
}

resource "aws_alb_listener_rule" "https_rule" {
  listener_arn = var.https_listener_arn
  priority     = var.http_rule_priority

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.target.arn
  }

  condition {
    field  = "host-header"
    values = ["${var.url}.${var.domain}"]
  }
}

data "template_file" "ecs_template" {
  template = file("${path.module}/files/service.tpl.json")

  vars = {
    image_url                  = "${aws_ecr_repository.repository.repository_url}:latest"
    application_container_name = var.project
    application_memory         = var.application_memory
    nginx_container_name       = "${var.project}-nginx"
    nginx_image_url            = "${aws_ecr_repository.repository_nginx.repository_url}:latest"
    app                        = var.app
    project                    = var.project
    env                        = var.environment
    log_group                  = var.cluster_name
    REDIS_URL                  = var.REDIS_URL
    MONGODB_URI                = var.MONGODB_URI
    SESSION_SECRET             = var.SESSION_SECRET
    FACEBOOK_ID                = var.FACEBOOK_ID
    FACEBOOK_SECRET            = var.FACEBOOK_SECRET
  }
}

resource "aws_ecs_task_definition" "task" {
  family                = "${var.project}-${var.app}-${var.environment}"
  container_definitions = data.template_file.ecs_template.rendered
}

# Specify the family to find the latest ACTIVE revision in that family.
data "aws_ecs_task_definition" "task" {
  task_definition = aws_ecs_task_definition.task.family

  depends_on = [aws_ecs_task_definition.task]
}

resource "aws_ecs_service" "service" {
  name    = "${var.project}-${var.app}"
  cluster = var.cluster_name
  task_definition = "${aws_ecs_task_definition.task.family}:${max(
    aws_ecs_task_definition.task.revision,
    data.aws_ecs_task_definition.task.revision,
  )}"
  desired_count                      = 1
  deployment_minimum_healthy_percent = 50
  iam_role                           = var.ecs_iam_role

  load_balancer {
    target_group_arn = aws_alb_target_group.target.id
    container_name   = "${var.app}-nginx"
    container_port   = 80
  }
}
