variable "environment" {
}

variable "cluster_name" {
}

variable "bastion_sg_id" {
}

variable "vpc_id" {
}

variable "private_subnets" {
  type = list(string)
}

variable "public_subnets" {
  type = list(string)
}

variable "instance_type" {
  default = "t2.micro"
}

variable "desired_capacity" {
  default = "2"
}

variable "max_size" {
  default = "3"
}

variable "root_ebs_size" {
  default = "10"
}

