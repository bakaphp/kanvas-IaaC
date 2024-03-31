module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 18.0"

  cluster_name    = "${terraform.workspace}-${var.eks_cluster_name}"
  cluster_version = "1.29"

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  manage_aws_auth_configmap       = true

  vpc_id     = var.vpc_id
  subnet_ids = var.vpc_private_subnets

  enable_irsa = true

  eks_managed_node_group_defaults = {
    disk_size = 100
  }

  cluster_additional_security_group_ids = ["${var.eks_vpc_security_group_id}"]
  create_node_security_group            = false
  node_security_group_id                = var.eks_vpc_security_group_id

  eks_managed_node_groups = {
    general = {
      min_size     = 2
      max_size     = 20
      desired_size = 2

      instance_types       = ["${var.eks_cluster_ec2_instance_type}"]
      capacity_type        = "ON_DEMAND"
      force_update_version = true
      enable_monitoring    = true

      iam_role_additional_policies = [
        var.node_group_autoscaling_policy_arn
      ]

      labels = {
        role = local.nodegroup_label
      }

      tags = {
        "k8s.io/cluster-autoscaler/enabled"                                        = "true"
        "k8s.io/cluster-autoscaler/${terraform.workspace}-${var.eks_cluster_name}" = "owned"
        "k8s.io/cluster-autoscaler/node-template/label/role"                       = "${local.nodegroup_label}"
      }

      create_security_group = false
    }
  }
}

resource "aws_autoscaling_group_tag" "nodegroup1" {
  for_each               = local.eks_asg_tag_list_nodegroup
  autoscaling_group_name = element(module.eks.eks_managed_node_groups_autoscaling_group_names, 0)

  tag {
    key                 = each.key
    value               = each.value
    propagate_at_launch = true
  }
}
