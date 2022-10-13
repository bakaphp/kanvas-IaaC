terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.34"
    }
  }

  backend "s3" {
    bucket = "kanvas-iaac"
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
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "aws" {
  profile = "default"
  region  = var.aws_region
}

# module "eks-cluster" {
#   source          = "terraform-aws-modules/eks/aws"
#   cluster_name    = "${terraform.workspace}-${var.eks_cluster_name}"
#   cluster_version = "1.18"
#   subnets         = ["subnet-f458009a"]
#   vpc_id          = "vpc-fd580093"
#   enable_irsa     = true
#   # cluster_create_security_group = false
#   # cluster_security_group_id = "sg-99fe4ce6"
#   # worker_create_security_group = false
#   # worker_security_group_id = "sg-99fe4ce6"
  
#   worker_groups = [
#     {
#       name = "${terraform.workspace}",
#       instance_type = var.eks_cluster_ec2_instance_type
#       desired_capacity = 2
#       asg_max_size  = 3 
#       asg_min_size  = 0
      
#     }
#   ]
# }

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 18.0"

  cluster_name    = "${terraform.workspace}-${var.eks_cluster_name}"
  cluster_version = "1.22"

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  # cluster_addons = {
  #   coredns = {
  #     resolve_conflicts = "OVERWRITE"
  #   }
  #   kube-proxy = {}
  #   vpc-cni = {
  #     resolve_conflicts = "OVERWRITE"
  #   }
  # }

  # cluster_encryption_config = [{
  #   provider_key_arn = "arn:aws:kms:eu-west-1:111122223333:key/1234abcd-12ab-34cd-56ef-1234567890ab"
  #   resources        = ["secrets"]
  # }]

  vpc_id     = "vpc-fd580093"
  subnet_ids = ["subnet-f458009a","subnet-0f600f3d443a7e295"]

  # Self Managed Node Group(s)
  self_managed_node_group_defaults = {
    instance_type                          = var.eks_cluster_ec2_instance_type
    # update_launch_template_default_version = true
    # iam_role_additional_policies = [
    #   "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    # ]
  }

  self_managed_node_groups = {
    one = {
      name         = "${terraform.workspace}"
      max_size     = 3
      desired_size = 2

      # use_mixed_instances_policy = true
      # mixed_instances_policy = {
      #   instances_distribution = {
      #     on_demand_base_capacity                  = 0
      #     on_demand_percentage_above_base_capacity = 10
      #     spot_allocation_strategy                 = "capacity-optimized"
      #   }

      #   override = [
      #     {
      #       instance_type     = "m5.large"
      #       weighted_capacity = "1"
      #     },
      #     {
      #       instance_type     = "m6i.large"
      #       weighted_capacity = "2"
      #     },
      #   ]
      # }
    }
  }
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
resource "aws_iam_policy" "aws_alb_controller" {
  name = "${terraform.workspace}-${local._k8s_service_account_name}"
  description = "EKS cluster ALB controller for cluster ${terraform.workspace}-${local._k8s_service_account_name}"
  policy = file("policies/aws-load-balancer-controller.json")
}

module "iam_assumable_role_admin" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "3.6.0"
  create_role                   = true
  role_name                     = "${terraform.workspace}-${local._k8s_service_account_name}"
  provider_url                  = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = [aws_iam_policy.aws_alb_controller.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${terraform.workspace}:${terraform.workspace}-${local._k8s_service_account_name}"]
}

# Autoscaler Role and Policies
resource "aws_iam_policy" "aws_cluster_autoscaler" {
  name = "${terraform.workspace}-${local._k8s_service_account_autoscaler}"
  description = "EKS cluster autoscaler ${terraform.workspace}-${local._k8s_service_account_autoscaler}"
  policy = file("policies/cluster-autoscaler.json")
}

module "iam_assumable_role_admin_cluster_autoscaler" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "3.6.0"
  create_role                   = true
  role_name                     = "${terraform.workspace}-${local._k8s_service_account_autoscaler}"
  provider_url                  = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = [aws_iam_policy.aws_cluster_autoscaler.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${terraform.workspace}:${terraform.workspace}-${local._k8s_service_account_autoscaler}"]
}
