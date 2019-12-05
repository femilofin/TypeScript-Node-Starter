resource "aws_elasticache_subnet_group" "redis" {
  name = "${var.project}-${var.environment}"
  subnet_ids = var.private_subnet_ids
}

resource "aws_elasticache_cluster" "redis" {
  cluster_id        = "${var.project}-${var.environment}"
  engine            = "redis"
  subnet_group_name = aws_elasticache_subnet_group.redis.name
  security_group_ids   = [var.security_group_id]
  node_type            = var.node_type
  port                 = 6379
  num_cache_nodes      = 1
  parameter_group_name = "default.redis5.0"
  engine_version       = var.engine_version
}

output "address" {
  value = aws_elasticache_cluster.redis.cache_nodes.0.address
}
