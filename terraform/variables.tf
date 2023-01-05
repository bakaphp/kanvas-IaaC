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
