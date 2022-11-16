module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 18.0"

  cluster_name    = "${terraform.workspace}-${var.eks_cluster_name}"
  cluster_version = "1.23"

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  manage_aws_auth_configmap = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  enable_irsa = true

  eks_managed_node_group_defaults = {
    disk_size      = 100
  }

  eks_managed_node_groups = {
    general = {
      min_size     = 1
      max_size     = 2
      desired_size = 1

      instance_types = [var.eks_cluster_ec2_instance_type]
      capacity_type  = "ON_DEMAND"

      labels = {
        role = "general"
      }

      create_security_group          = true
      security_group_name            = "kanvas-iaac-security-group"
      security_group_use_name_prefix = false
      security_group_description     = "Kanvas EKS Security Group"
      security_group_rules = {
        DbIn = {
          description = "Database Inbound Rule"
          protocol    = "tcp"
          from_port   = 3306
          to_port     = 3306
          type        = "ingress"
          cidr_blocks = [module.vpc.default_vpc_cidr_block]
        }
        DbOut = {
          description                   = "Database Inbound Rule"
          protocol    = "tcp"
          from_port   = 3306
          to_port     = 3306
          type        = "ingress"
          cidr_blocks = [module.vpc.default_vpc_cidr_block]
        }
      }
      security_group_tags = {
        Purpose = "Let all services in"
      }
    }
  }
}