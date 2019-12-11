resource "aws_s3_bucket" "artifacts" {
  bucket = "${var.project}-artifacts"
  acl    = "private"
}

data "template_file" "buildspec" {
  template = file("${path.module}/files/buildspec.yml")

  vars = {
    repository_url       = var.repository_url
    nginx_repository_url = var.nginx_repository_url
    region               = var.region
    cluster_name         = var.ecs_cluster_name
    domain               = var.domain
  }
}

resource "aws_codebuild_project" "default" {
  name         = var.project
  service_role = aws_iam_role.cb_role.arn

  source {
    type      = "CODEPIPELINE"
    buildspec = data.template_file.buildspec.rendered
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/docker:1.12.1"
    type            = "LINUX_CONTAINER"
    privileged_mode = true
  }

  artifacts {
    type = "CODEPIPELINE"
  }
}

output "name" {
  value = aws_codebuild_project.default.id
}

output "artifacts_bucket" {
  value = aws_s3_bucket.artifacts.bucket
}

output "artifacts_bucket_arn" {
  value = aws_s3_bucket.artifacts.arn
}
