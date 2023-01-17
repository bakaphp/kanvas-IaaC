terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.34"
    }
  }

  backend "s3" {
    bucket = "kanvas-laravel-iaac"
    key    = "states"
    workspace_key_prefix = "tf-states"
    region = "us-east-1"
  }
}

# EKS Cluster
data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "aws" {
  region  = var.aws_region
}

resource "aws_security_group_rule" "allow_db_in" {
  description = "Database Inbound Rule"
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks = "${var.vpc_cidr_block}"
  security_group_id = "${var.eks_vpc_security_group_id}"
}

resource "aws_security_group_rule" "allow_db_out" {
  description = "Database Outbound Rule"
  type              = "egress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks = "${var.vpc_cidr_block}"
  security_group_id = "${var.eks_vpc_security_group_id}"
}

resource "aws_security_group_rule" "allow_redis_in" {
  description = "Redis Inbound Rule"
  protocol    = "tcp"
  from_port   = 6379
  to_port     = 6379
  type        = "ingress"
  cidr_blocks = "${var.vpc_cidr_block}"
  security_group_id = "${var.eks_vpc_security_group_id}"
}

resource "aws_security_group_rule" "allow_redis_out" {
  description = "Redis Outbound Rule"
  type        = "egress"
  from_port   = 6379
  to_port     = 6379
  protocol    = "tcp"
  cidr_blocks = "${var.vpc_cidr_block}"
  security_group_id = "${var.eks_vpc_security_group_id}"
}

resource "aws_security_group_rule" "allow_mail_in" {
  description = "Mail Inbound Rule"
  protocol    = "tcp"
  from_port   = 587
  to_port     = 587
  type        = "ingress"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${var.eks_vpc_security_group_id}"
}

resource "aws_security_group_rule" "allow_mail_out" {
  description = "Mail Outbound Rule"
  protocol    = "tcp"
  from_port   = 587
  to_port     = 587
  type        = "egress"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${var.eks_vpc_security_group_id}"
}

resource "aws_security_group_rule" "allow_queue_in" {
  description = "Queue Inbound Rule"
  protocol    = "tcp"
  from_port   = 5672
  to_port     = 5672
  type        = "ingress"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${var.eks_vpc_security_group_id}"
}

resource "aws_security_group_rule" "allow_queue_out" {
  description = "Queue Outbound Rule"
  protocol    = "tcp"
  from_port   = 5672
  to_port     = 5672
  type        = "egress"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${var.eks_vpc_security_group_id}"
}

resource "aws_security_group_rule" "allow_metrics_in" {
  description = "Metrics Inbound Rule"
  protocol    = "tcp"
  from_port   = 4443
  to_port     = 4443
  type        = "ingress"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${var.eks_vpc_security_group_id}"
}

resource "aws_security_group_rule" "allow_metrics_out" {
  description = "Metrics Outbound Rule"
  protocol    = "tcp"
  from_port   = 4443
  to_port     = 4443
  type        = "egress"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${var.eks_vpc_security_group_id}"
}

resource "aws_security_group_rule" "allow_prometheus_in" {
  description = "Prometheus Inbound Rule"
  protocol    = "tcp"
  from_port   = 9090
  to_port     = 9090
  type        = "ingress"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${var.eks_vpc_security_group_id}"
}

resource "aws_security_group_rule" "allow_prometheus_out" {
  description = "Prometheus Outbound Rule"
  protocol    = "tcp"
  from_port   = 9090
  to_port     = 9090
  type        = "egress"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${var.eks_vpc_security_group_id}"
}


