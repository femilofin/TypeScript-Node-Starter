variable "environment" {}

module "vpc" {
  # Ref: https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/2.21.0
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.21.0"

  name = "${var.environment}-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway   = "true"
  enable_dns_hostnames = "true"
  single_nat_gateway   = "true"

  public_subnet_tags = {
    Tier = "public"
  }

  private_subnet_tags = {
    Tier = "private"
  }

  tags = {
    Terraform   = "true"
    Environment = "${var.environment}"
  }
}

output "public_subnets" {
  value = "${module.vpc.public_subnets}"
}

output "private_subnets" {
  value = "${module.vpc.private_subnets}"
}

output "vpc_id" {
  value = "${module.vpc.vpc_id}"
}
