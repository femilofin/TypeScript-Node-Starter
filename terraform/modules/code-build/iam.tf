data "template_file" "cb_role" {
  template = file("${path.module}/files/code_build_role.tpl.json")
}

resource "aws_iam_role" "cb_role" {
  assume_role_policy = data.template_file.cb_role.rendered
  name               = "${var.project}-code-build"
}

data "template_file" "cb_policy" {
  template = file("${path.module}/files/code_build_policy.tpl.json")

  vars = {
    s3_bucket_arn = aws_s3_bucket.artifacts.arn
  }
}

resource "aws_iam_role_policy" "cb_policy" {
  name   = "CodeBuild-${var.project}"
  role   = aws_iam_role.cb_role.name
  policy = data.template_file.cb_policy.rendered
}
