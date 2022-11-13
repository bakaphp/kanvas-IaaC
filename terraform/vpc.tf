module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = local.vpc_name
  cidr = "10.0.0.0/16"

  azs             = ["${local.aws_region}a", "${local.aws_region}b"]
  private_subnets = ["10.0.128.0/20", "10.0.144.0/20"]
  public_subnets  = ["10.0.0.0/20", "10.0.16.0/20"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    "Environment" = "development"
  }
}