variable "eks_cluster_name" {
  type        = string
  description = "The id of the machine image (AMI) to use for the server."
  default = "kanvas-cluster"
}

variable "eks_cluster_ec2_instance_type" {
  type        = string
  description = "The machine width for the worker node."
  default = "m5.large"
}

variable "aws_region" {
  type        = string
  description = "The aws target region."
  default = "us-east-1"
}
