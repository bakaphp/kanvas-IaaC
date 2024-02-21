locals {
  _aws_env_s3_bucket_prefix_key = terraform.workspace
  aws_region                    = "us-east-1"
  nodegroup_label = "general"
  eks_asg_tag_list_nodegroup = {
    "k8s.io/cluster-autoscaler/enabled" : true
    "k8s.io/cluster-autoscaler/${terraform.workspace}-${var.eks_cluster_name}" : "owned"
    "k8s.io/cluster-autoscaler/node-template/label/role" : local.nodegroup_label
  }
  k8s_service_account_namespace = "kube-system"
  k8s_service_account_name      = "cluster-autoscaler"
}