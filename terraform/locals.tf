locals {
  _aws_env_s3_bucket_prefix_key = "${terraform.workspace}"
  vpc_name = "kanvas-iaac-vpc"
  aws_region = "us-east-1"
}