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

# # Create Custom EKS IAM GROUP
# resource "aws_iam_group" "eks_group" {
#   name = "${terraform.workspace}-${local._aws_eks_iam_group}"
#   path = "/users/"
# }

# # S3 Policies
# resource "aws_iam_group_policy" "s3_policies" {
#   name = "s3_custom_policies"
#   group = aws_iam_group.eks_group.name

#   policy = jsonencode({
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Effect": "Allow",
#             "Action": "s3:*",
#             "Resource": "*"
#         }
#     ]
#   })
# }

# # EKS Policies
# resource "aws_iam_group_policy" "eks_policies" {
#   name = "eks_custom_policies"
#   group = aws_iam_group.eks_group.name

#   policy = jsonencode({
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Sid": "VisualEditor0",
#             "Effect": "Allow",
#             "Action": [
#                 "eks:ListClusters",
#                 "eks:DescribeAddonVersions",
#                 "eks:CreateCluster"
#             ],
#             "Resource": "*"
#         },
#         {
#             "Sid": "VisualEditor1",
#             "Effect": "Allow",
#             "Action": "eks:*",
#             "Resource": "arn:aws:eks:*:617498580299:cluster/*"
#         }
#     ]
#   })
# }

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

