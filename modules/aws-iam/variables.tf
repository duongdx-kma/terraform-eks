variable "cluster_name" {
  type = string
  description = "The eks cluster name"
}

variable "tags" {
  type = map(any)
}