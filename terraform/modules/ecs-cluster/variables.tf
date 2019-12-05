variable "environment" {
}

variable "cluster_name" {
}

variable "vpc_id" {
}

variable "bastion_sg_id" {
}

variable "domain" {
}

variable "private_subnets" {
  type = list(string)
}

variable "public_subnets" {
  type = list(string)
}

