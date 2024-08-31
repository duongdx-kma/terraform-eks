variable "cluster_name" {
  type = string
  description = "The eks cluster name"
}

variable "cluster_version" {
  description = "The Desired Kubernetes master version, if we don't define cluster will using K8S latest version"
  type = string
  default = null
}

variable vpc_subnet_ids {
  type = list(string)
  description = "The list of VPC subnet ids"
}

variable "tags" {
  type = map(any)
}

variable "public_node_group_scaling_config" {
  description = "The auto scaling configuration"
  type = object({
    desired_size = number
    min_size     = number
    max_size     = number
  })

  default = {
    desired_size = 1
    min_size     = 1
    max_size     = 1
  }
}

variable "private_node_group_scaling_config" {
  description = "The auto scaling configuration"
  type = object({
    desired_size = number
    min_size     = number
    max_size     = number
  })

  default = {
    desired_size = 1
    min_size     = 1
    max_size     = 1
  }
}

variable "node_group_path_to_public_key" {
  description = "The path to public key"
  type = string
}

variable "node_group_ami_type" {
  description = "The node group AMI architecture"
  type = string
  default = "AL2_x86_64"
}

variable "node_group_capacity_type" {
  description = "The node group capacity type"
  type = string
  default = "ON_DEMAND"
}

variable "node_group_disk_size" {
  description = "The node group disk size"
  type = number
  default = 20
}

variable "node_group_instance_types" {
  description = "The node group instance types"
  type = list(string)
  default = ["t3.medium"]
}

variable "node_group_vpc_public_subnet_ids" {
  type = list(string)
  description = "The list of VPC Public subnet ids"
}

variable "node_group_vpc_private_subnet_ids" {
  type = list(string)
  description = "The list of VPC Public subnet ids"
}

variable node_group_role_arn {
  description = "The node group role arn"
  type = string
}