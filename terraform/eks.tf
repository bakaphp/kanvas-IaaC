module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 18.0"

  cluster_name    = "${terraform.workspace}-${var.eks_cluster_name}"
  cluster_version = "1.23"

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  
  # create_aws_auth_configmap = true
  # manage_aws_auth_configmap = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  enable_irsa = true

  # Self Managed Node Group(s)
#   self_managed_node_group_defaults = {
#     instance_type                          = var.eks_cluster_ec2_instance_type
#     update_launch_template_default_version = true
#     iam_role_additional_policies = [
#       "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
#     ]
#   }

#   self_managed_node_groups = {
#     elk_1 = {
#       name         = "${terraform.workspace}"
#       platform      = "elk_1"
#       ami_id        = "ami-0d6e9a57f6259ba3a"
#       instance_type = var.eks_cluster_ec2_instance_type
#       max_size     = 2
#       desired_size = 1
#       min_size     = 1
#       iam_role_additional_policies = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
#       subnet_ids = ["subnet-04672afebeda67752","subnet-023f96ede59ede20b"]

#       launch_template_name            = "kanvas"
#       launch_template_use_name_prefix = true
#       launch_template_description     = "Self managed node group example launch template"

#       vpc_security_group_ids = ["sg-01aba248254780a61"]
#       enable_monitoring      = true
#     }
#   }

  eks_managed_node_group_defaults = {
    disk_size      = 100
  }

  eks_managed_node_groups = {
    general = {
      min_size     = 1
      max_size     = 2
      desired_size = 1
      subnet_ids = module.vpc.public_subnets

      instance_types = [var.eks_cluster_ec2_instance_type]
      capacity_type  = "ON_DEMAND"

      labels = {
        role = "general"
      }
    }
  }
}