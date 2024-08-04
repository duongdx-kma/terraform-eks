variable "cluster_name" {
  type = string
  description = "The eks cluster name"
}

variable vpc_subnet_ids {
  type = list(string)
  description = "The list of VPC subnet ids"
}

variable "tags" {
  type = map(any)
}