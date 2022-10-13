locals {
  _k8s_service_account_name       = "aws-load-balancer-controller"
  _k8s_service_account_autoscaler = "cluster-autoscaler"
  _aws_eks_iam_group              = "cluster_eks_group"
  
  _aws_env_s3_bucket_prefix_key    = "${terraform.workspace}"
}