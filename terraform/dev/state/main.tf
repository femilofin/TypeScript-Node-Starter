provider "aws" {
  region = "eu-west-1"
}

resource "aws_s3_bucket" "state" {
  bucket = "${var.project}-states-${var.environment}"
  acl    = "private"
}
