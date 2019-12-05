resource "aws_ecs_cluster" "cluster" {
  name = var.cluster_name
}

# Creates ECS cluster and SG's
module "autoscaling" {
  source          = "../autoscaling"
  environment     = var.environment
  cluster_name    = var.cluster_name
  bastion_sg_id   = var.bastion_sg_id
  vpc_id          = var.vpc_id
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
}

output "ecs_iam_role" {
  value = module.autoscaling.ecs_iam_role
}

output "internal_sg_id" {
  value = module.autoscaling.internal_sg_id
}
