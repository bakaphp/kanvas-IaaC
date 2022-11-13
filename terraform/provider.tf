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

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_id]
  }
}

provider "aws" {
  region  = var.aws_region
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 18.0"

  cluster_name    = "${terraform.workspace}-${var.eks_cluster_name}"
  cluster_version = "1.23"

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  
  create_aws_auth_configmap = true
  manage_aws_auth_configmap = true

  vpc_id     = "vpc-03211d22607acb3ba"
  subnet_ids = ["subnet-065ed8e3781ef76e4","subnet-02823c2b6c9ef2aab"]

  # Self Managed Node Group(s)
  self_managed_node_group_defaults = {
    instance_type                          = var.eks_cluster_ec2_instance_type
    update_launch_template_default_version = true
    iam_role_additional_policies = [
      "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    ]
  }

  self_managed_node_groups = {
    elk_1 = {
      name         = "${terraform.workspace}"
      platform      = "elk_1"
      ami_id        = "ami-0d6e9a57f6259ba3a"
      instance_type = var.eks_cluster_ec2_instance_type
      max_size     = 2
      desired_size = 1
      min_size     = 1
      iam_role_additional_policies = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
      subnet_ids = ["subnet-04672afebeda67752","subnet-023f96ede59ede20b"]

      launch_template_name            = "kanvas"
      launch_template_use_name_prefix = true
      launch_template_description     = "Self managed node group example launch template"
    }
  }

  # eks_managed_node_group_defaults = {
  #   disk_size      = 50
  #   instance_types = [var.eks_cluster_ec2_instance_type]
  # }

  # eks_managed_node_groups = {
  #   blue = {}
  #   green = {
  #     min_size     = 1
  #     max_size     = 2
  #     desired_size = 1

  #     instance_types = [var.eks_cluster_ec2_instance_type]
  #     capacity_type  = "SPOT"
  #   }
  # }
}

# Create Custom EKS IAM GROUP
resource "aws_iam_group" "eks_group" {
  name = "${terraform.workspace}-${local._aws_eks_iam_group}"
  path = "/users/"
}

# S3 Policies
resource "aws_iam_group_policy" "s3_policies" {
  name = "s3_custom_policies"
  group = aws_iam_group.eks_group.name

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": "*"
        }
    ]
  })
}

# EKS Policies
resource "aws_iam_group_policy" "eks_policies" {
  name = "eks_custom_policies"
  group = aws_iam_group.eks_group.name

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "eks:ListClusters",
                "eks:DescribeAddonVersions",
                "eks:CreateCluster"
            ],
            "Resource": "*"
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": "eks:*",
            "Resource": "arn:aws:eks:*:617498580299:cluster/*"
        }
    ]
  })
}

# LoadBalancer Role and Policies
# resource "aws_iam_policy" "aws_alb_controller" {
#   name = "${terraform.workspace}-${local._k8s_service_account_name}"
#   description = "EKS cluster ALB controller for cluster ${terraform.workspace}-${local._k8s_service_account_name}"
#   policy = file("policies/aws-load-balancer-controller.json")
# }

# module "iam_assumable_role_admin" {
#   source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
#   version                       = "3.6.0"
#   create_role                   = true
#   role_name                     = "${terraform.workspace}-${local._k8s_service_account_name}"
#   provider_url                  = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
#   role_policy_arns              = [aws_iam_policy.aws_alb_controller.arn]
#   oidc_fully_qualified_subjects = ["system:serviceaccount:${terraform.workspace}:${terraform.workspace}-${local._k8s_service_account_name}"]
# }

# # Autoscaler Role and Policies
# resource "aws_iam_policy" "aws_cluster_autoscaler" {
#   name = "${terraform.workspace}-${local._k8s_service_account_autoscaler}"
#   description = "EKS cluster autoscaler ${terraform.workspace}-${local._k8s_service_account_autoscaler}"
#   policy = file("policies/cluster-autoscaler.json")
# }

# module "iam_assumable_role_admin_cluster_autoscaler" {
#   source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
#   version                       = "3.6.0"
#   create_role                   = true
#   role_name                     = "${terraform.workspace}-${local._k8s_service_account_autoscaler}"
#   provider_url                  = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
#   role_policy_arns              = [aws_iam_policy.aws_cluster_autoscaler.arn]
#   oidc_fully_qualified_subjects = ["system:serviceaccount:${terraform.workspace}:${terraform.workspace}-${local._k8s_service_account_autoscaler}"]
# }

