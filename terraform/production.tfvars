eks_cluster_name              = "kanvas-cluster"
eks_cluster_ec2_instance_type = "m5.large"
aws_region                    = "us-east-1"
vpc_cidr_block                = ["172.31.0.0/20", "172.31.16.0/20"]
vpc_id                        = "vpc-d43d19b2"
vpc_private_subnets           = ["subnet-0cf4b169", "subnet-abb547e3"]
eks_vpc_security_group_id     = "sg-017dc5e5c295c88d2"
node_group_autoscaling_policy_arn = "arn:aws:iam::617498580299:policy/KanvasDevClusterAutoscalerPolicy"