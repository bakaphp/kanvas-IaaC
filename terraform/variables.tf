variable "eks_cluster_name" {
  type        = string
  description = "The cluster name"
  default = "kanvas-cluster"
}

variable "eks_cluster_ec2_instance_type" {
  type        = string
  description = "The EC2 instance type"
  default = "m5.large"
}

variable "aws_region" {
  type        = string
  description = "The aws target region."
  default = "us-east-1"
}

variable "vpc_cidr_block" {
  type        = string
  description = "The aws target region."
  default = "10.0.0.0/16"
}

variable "vpc_id" {
  type        = string
  description = "The VPC id"
  default = "vpc-04cfab9da09e8ededs"
}

variable "vpc_private_subnets" {
  type        = list
  description = "The VPC private subnets"
  default = ["subnet-ac6019de","subnet-ac6019ss"]
}
