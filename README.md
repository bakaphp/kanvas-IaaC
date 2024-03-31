# AWS EKS Cluster IaC

Deploy a AWS EKS Cluster using Terraform in minutes.

## Setup

### Set you AWS account credentials on Github Repo

1.On your Github Repo `Settings`, in `Action` under `Secrets and variables` create two new `Repository Secrets` and their corresponding values:

* `AWS_ACCESS_KEY_ID`: AWS Account Access Key

* `AWS_SECRET_ACCESS_KEY`: AWS Account Secret Key

## Set you tf states bucket

1. On AWS create a new bucket where the terraform states will be stored.

2. Change the name of the bucket in the backend s3 configuration on the `provider.tf` file. On `bucket` replace the existing value with your own bucket name.

### Setting tfvars as Github Secrets

Instead of using a `.tfvars` for storing the different variable values, Github environments secrets are used.The following steps cover how to do it:

1. On your Github Repo `Settings`, in `Action` under `Secrets and variables` create a new environment. For example: `development`

2. Create the following secrets and add the corresponding types of values for each one. These are the ones set for this project:

    * `AWS_REGION`: ex: us-east-1
    * `EKS_CLUSTER_EC2_INSTANCE_TYPE`: ex: m3.large
    * `EKS_VPC_SECURITY_GROUP_ID`: ex: sg-062f05b98b1edfefaeasdadaedaed
    * `EKS_MIN_NODE_SIZE`: 1
    * `EKS_DESIRED_NODE_SIZE`: 2
    * `EKS_MAX_NODE_SIZE`: 10
    * `NODE_GROUP_AUTOSCALING_POLICY_ARN`: ex: arn:aws:iam::23428842523567:policy/NameOFTHEPOLICY
    * `EKS_CLUSTER_NAME`: ex: example-cluster
    * `VPC_CIDR_BLOCK`: ex: 10.1.0.0/16
    * `VPC_ID`: ex: vpc-232fsr9fs9229frf
    * `VPC_PRIVATE_SUBNETS_1`: ex: subnet-22938423489239"
    * `VPC_PRIVATE_SUBNETS_2`: ex: subnet-22938423489224"

## How to Deploy

To deploy a new cluster with the given values just go to the `Actions` section of you repository and click on the `Deploy/update infrastructure`. There, go the `Run workflow` button and choose the environment you wish to deploy. The deployment will begin. It should take about 10 minutes for the cluster to be deployed on AWS EKS.


## Installing the cluster autoscaler

For now the installation must be done after the cluster is created via helm using the following commands:

Add the repo:
```sh
helm repo add autoscaler https://kubernetes.github.io/autoscaler
```

Install the chart on the cluster:

```sh
helm install my-release autoscaler/cluster-autoscaler \
    --set autoDiscovery.clusterName=<CLUSTER NAME> \
    --set awsRegion=<YOUR AWS REGION>
```


## Installing Metrics Server

To install the metrics server use the following command:


```sh
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```


# Autoscaling permissions on AWS

Create an Autoscaler Policy in AWS to attach to the cluster. Use the following configuration:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeAutoScalingInstances",
                "autoscaling:DescribeLaunchConfigurations",
                "autoscaling:DescribeTags",
                "autoscaling:SetDesiredCapacity",
                "autoscaling:TerminateInstanceInAutoScalingGroup",
                "ec2:DescribeLaunchTemplateVersions"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
```