resource "aws_iam_user" "ci_user" {
  name = "${var.project}-${var.app}-${var.environment}-user"
  path = "/ecs/"
}

data "template_file" "ci_user_policy" {
  template = file("${path.module}/files/ci_user_policy.tpl.json")
}

resource "aws_iam_user_policy" "ci_user_policy" {
  name   = "ecs_deployer_policy"
  user   = aws_iam_user.ci_user.name
  policy = data.template_file.ci_user_policy.rendered
}

resource "aws_iam_access_key" "ci_user" {
  user = aws_iam_user.ci_user.name
}

output "ci_user_access_key" {
  value = aws_iam_access_key.ci_user.id
}

output "ci_user_secret_key" {
  value = aws_iam_access_key.ci_user.secret
}
