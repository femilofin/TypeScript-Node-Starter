data "template_file" "widget" {
  template = file("${path.module}/templates/metrics.tpl.json")
  vars = {
    service_name = var.service_name
    cluster_name = var.cluster_name
  }
}

resource "aws_cloudwatch_dashboard" "metrics" {
  dashboard_name = "${var.service_name}-${var.environment}"
  dashboard_body = data.template_file.widget.rendered
}
