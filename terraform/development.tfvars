eks_cluster_name                  = "kanvas-cluster"
eks_cluster_ec2_instance_type     = "m5.large"
aws_region                        = "us-east-1"
vpc_cidr_block                    = ["10.0.0.0/16"]
vpc_id                            = "vpc-009b3d0e1a8c6be05"
vpc_private_subnets               = ["subnet-0e3f6117178174d3e", "subnet-01be40b360004236c"]
eks_vpc_security_group_id         = "sg-01c93827afda2b627"
node_group_autoscaling_policy_arn = "arn:aws:iam::617498580299:policy/KanvasDevClusterAutoscalerPolicy"