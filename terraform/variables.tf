variable "eks_cluster_name" {
  type        = string
  description = "The id of the machine image (AMI) to use for the server."
  default = "kanvas_cluster"
}

variable "eks_cluster_ec2_instance_type" {
  type        = string
  description = "The machine width for the worker node."
  default = "t2.large"
}

variable "aws_region" {
  type        = string
  description = "The aws target region."
  default = "us-east-1"
}
# variable "aws_account_id" {
#   type        = string
#   description = "The id of the machine image (AMI) to use for the server."
#   default = "346494590871"
# }

# variable "aws_env_s3_bucket_name" {
#   type        = string
#   description = "The id of the machine image (AMI) to use for the server."
#   default = "kanvas-iaac"
# }
