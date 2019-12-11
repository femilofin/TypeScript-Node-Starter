data "template_file" "cp_role" {
  template = file("${path.module}/files/code_pipeline_role.tpl.json")
}

resource "aws_iam_role" "cp_role" {
  assume_role_policy = data.template_file.cp_role.rendered
  name               = "${var.project}-code-pipeline"
}

data "template_file" "cp_policy" {
  template = file("${path.module}/files/code_pipeline_policy.tpl.json")

  vars = {
    s3_bucket_arn = var.artifacts_bucket_arn
  }
}

resource "aws_iam_role_policy" "cp_policy" {
  name   = "CodePipeline-${var.project}"
  role   = aws_iam_role.cp_role.name
  policy = data.template_file.cp_policy.rendered
}
