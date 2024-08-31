# Create AWS EKS Node Group - PUBLIC
resource "aws_eks_node_group" "eks_node_group_pubic" {
  cluster_name    = var.cluster_name
  node_group_name = "${var.cluster_name}-node-group-public"
  node_role_arn   = var.node_group_role_arn
  subnet_ids      = var.node_group_vpc_public_subnet_ids

  scaling_config {
    desired_size = var.public_node_group_scaling_config.desired_size
    min_size     = var.public_node_group_scaling_config.min_size
    max_size     = var.public_node_group_scaling_config.max_size
  }

  ami_type       = var.node_group_ami_type
  capacity_type  = var.node_group_capacity_type
  disk_size      = var.node_group_disk_size
  instance_types = var.node_group_instance_types

  remote_access {
    ec2_ssh_key = aws_key_pair.node_group_key.key_name
    # source_security_group_ids = ["security_group_id"] # Any IP address can access the node-group instances.
  }

  # The maximum number of unavailable instances when the node group is being updated/upgraded.
  # it means that when node group is being update or update. only `1` instance will be updated at a time
  update_config {
    max_unavailable = 1
    #max_unavailable_percentage = 50    # ANY ONE TO USE
  }

  # Kubernetes config
  version = var.cluster_version

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  # depends_on = [
  #   aws_iam_role_policy_attachment.eks-AmazonEKSWorkerNodePolicy,
  #   aws_iam_role_policy_attachment.eks-AmazonEKS_CNI_Policy,
  #   aws_iam_role_policy_attachment.eks-AmazonEC2ContainerRegistryReadOnly,
  # ]

  tags = merge({
    NodeGroupType = "public"
  }, var.tags)
}
