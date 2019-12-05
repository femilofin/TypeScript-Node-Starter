terraform {
  backend "s3" {
    bucket = "typescript-node-starter-states-dev"
    key    = "terraform.tfstate"
    region = "eu-west-1"
  }
}

