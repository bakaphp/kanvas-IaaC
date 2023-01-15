module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 18.0"

  cluster_name    = "${terraform.workspace}-${var.eks_cluster_name}"
  cluster_version = "1.23"

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  manage_aws_auth_configmap = true

  vpc_id     = "${var.vpc_id}"
  subnet_ids = "${var.vpc_private_subnets}"

  enable_irsa = true

  eks_managed_node_group_defaults = {
    disk_size      = 100
  }

  eks_managed_node_groups = {
    general = {
      min_size     = 1
      max_size     = 3
      desired_size = 2

      instance_types = ["${var.eks_cluster_ec2_instance_type}"]
      capacity_type  = "ON_DEMAND"
      force_update_version = true
      enable_monitoring       = true

      labels = {
        role = "general"
      }

      # create_security_group          = false
      # security_group_name            = "${terraform.workspace}-kanvas-iaac-security-group"
      # security_group_use_name_prefix = false
      # security_group_description     = "Kanvas EKS Security Group"

      security_group_id = var.eks_vpc_security_group_id
      security_group_rules = {
        DbIn = {
          description = "Database Inbound Rule"
          protocol    = "tcp"
          from_port   = 3306
          to_port     = 3306
          type        = "ingress"
          cidr_blocks = "${var.vpc_cidr_block}"
        }
        DbOut = {
          description = "Database Outbound Rule"
          protocol    = "tcp"
          from_port   = 3306
          to_port     = 3306
          type        = "egress"
          cidr_blocks = "${var.vpc_cidr_block}"
        }
        RedisIn = {
          description = "Redis Inbound Rule"
          protocol    = "tcp"
          from_port   = 6379
          to_port     = 6379
          type        = "ingress"
          cidr_blocks = "${var.vpc_cidr_block}"
        }
        RedisOut = {
          description = "Redis Outbound Rule"
          protocol    = "tcp"
          from_port   = 6379
          to_port     = 6379
          type        = "egress"
          cidr_blocks = "${var.vpc_cidr_block}"
        }
        MailIn = {
          description = "Mail Inbound Rule"
          protocol    = "tcp"
          from_port   = 587
          to_port     = 587
          type        = "ingress"
          cidr_blocks = ["0.0.0.0/0"]
        }
        MailOut = {
          description = "Mail Outbound Rule"
          protocol    = "tcp"
          from_port   = 587
          to_port     = 587
          type        = "egress"
          cidr_blocks = ["0.0.0.0/0"]
        }
        QueueIn = {
          description = "Queue Inbound Rule"
          protocol    = "tcp"
          from_port   = 5672
          to_port     = 5672
          type        = "ingress"
          cidr_blocks = ["0.0.0.0/0"]
        }
        QueueOut = {
          description = "Queue Outbound Rule"
          protocol    = "tcp"
          from_port   = 5672
          to_port     = 5672
          type        = "egress"
          cidr_blocks = ["0.0.0.0/0"]
        }
        QueueTLSIn = {
          description = "TLS Queue Inbound Rule"
          protocol    = "tcp"
          from_port   = 5671
          to_port     = 5671
          type        = "ingress"
          cidr_blocks = ["0.0.0.0/0"]
        }
        QueueTLSOut = {
          description = "TLS Queue Outbound Rule"
          protocol    = "tcp"
          from_port   = 5671
          to_port     = 5671
          type        = "egress"
          cidr_blocks = ["0.0.0.0/0"]
        }
        MetricsIn = {
          description = "Metrics Inbound Rule"
          protocol    = "tcp"
          from_port   = 4443
          to_port     = 4443
          type        = "ingress"
          cidr_blocks = ["0.0.0.0/0"]
        }
        MetricsOut = {
          description = "Metrics Outbound Rule"
          protocol    = "tcp"
          from_port   = 4443
          to_port     = 4443
          type        = "egress"
          cidr_blocks = ["0.0.0.0/0"]
        }
        PrometheusIn = {
          description = "Prometheus Inbound Rule"
          protocol    = "tcp"
          from_port   = 9090
          to_port     = 9090
          type        = "ingress"
          cidr_blocks = ["0.0.0.0/0"]
        }
        PrometheusOut = {
          description = "Prometheus Outbound Rule"
          protocol    = "tcp"
          from_port   = 9090
          to_port     = 9090
          type        = "egress"
          cidr_blocks = ["0.0.0.0/0"]
        }
      }
      security_group_tags = {
        Purpose = "Let all services in"
      }
    }
  }
}