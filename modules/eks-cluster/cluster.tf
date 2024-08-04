resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn

  /**
  * Terraform document: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster
  * Kubernetes configuration
  */

  # Kubernetes version
  version = var.cluster_version

  # Kubernetes cluster ip ranges
  kubernetes_network_config {
    service_ipv4_cidr = var.cluster_service_ipv4_cidr

  }

  /**
  * AWS Document: https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html
  * AWS Document: https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html
  */
  vpc_config {
    subnet_ids              = var.vpc_subnet_ids
    endpoint_private_access = var.cluster_endpoint_private_access
    endpoint_public_access  = var.cluster_endpoint_public_access
    public_access_cidrs     = var.cluster_endpoint_public_access_cidrs
  }

  # Enable EKS Cluster Control Plane Logging
  # EKS Control Plane Logging can be enabled via the enabled_cluster_log_types argument. To manage the CloudWatch Log Group retention period, the aws_cloudwatch_log_group resource can be used.
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.eks-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks-AmazonEKSVPCResourceController,
  ]

  tags = var.tags
}


resource "aws_cloudwatch_log_group" "eks_cluster_cloudwatch_log_group" {
  # The log group name format is /aws/eks/<cluster-name>/cluster
  # Reference: https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = 7

  # ... potentially other configuration ...
}