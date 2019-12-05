provider "aws" {
  region = "eu-west-1"
}

module "vpc" {
  source      = "../modules/vpc"
  environment = var.environment
}

resource "aws_key_pair" "dev" {
  key_name   = var.environment
  public_key = var.public_key
}

module "bastion" {
  source         = "../modules/bastion"
  environment    = var.environment
  vpc_id         = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnets
}

module "ecs" {
  source          = "../modules/ecs-cluster"
  environment     = var.environment
  cluster_name    = var.cluster_name
  vpc_id          = module.vpc.vpc_id
  bastion_sg_id   = module.bastion.bastion_sg_id
  private_subnets = module.vpc.private_subnets
  public_subnets  = module.vpc.public_subnets
  domain          = var.domain
}

module "elasticache" {
  source             = "../modules/elasticache"
  environment        = var.environment
  project            = var.project
  engine_version     = var.redis_engine_version
  node_type          = var.elasticache_node_type
  security_group_id  = module.ecs.internal_sg_id
  private_subnet_ids = module.vpc.private_subnets
}

module "ecs-service" {
  source             = "../modules/ecs-service"
  project            = var.project
  app                = var.app
  environment        = var.environment
  health_check       = var.health_check
  http_rule_priority = var.http_rule_priority
  domain             = var.domain
  url                = var.url
  alb_dns_name       = module.ecs.alb_dns_name
  alb_zone_id        = module.ecs.alb_zone_id
  http_listener_arn  = module.ecs.http_listener_arn
  https_listener_arn = module.ecs.https_listener_arn
  application_memory = var.application_memory
  vpc_id             = module.vpc.vpc_id
  cluster_name       = var.cluster_name
  ecs_iam_role       = module.ecs.ecs_iam_role
  REDIS_URL          = module.elasticache.address
  MONGODB_URI        = var.MONGODB_URI
  SESSION_SECRET     = var.SESSION_SECRET
  FACEBOOK_ID        = var.FACEBOOK_ID
  FACEBOOK_SECRET    = var.FACEBOOK_SECRET
}

module "ci-user" {
  source      = "../modules/ci-user"
  environment = var.environment
  project     = var.project
  app         = var.app
}

output "ci_user_access_key" {
  value = module.ci-user.ci_user_access_key
}

output "ci_user_secret_key" {
  value = module.ci-user.ci_user_secret_key
}
