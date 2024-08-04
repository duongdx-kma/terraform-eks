variable "module_name" {
  type = string
}

variable "instance_name" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "path_to_public_key" {
  type = string
}

variable "path_to_private_key" {
  type = string
}

variable "path_to_public_node_group_key" {
  type = string
}

variable "vpc_security_group_ids" {
  type = list(string)
}

variable "subnet_id" {
  type = string
}

variable "tags" {
  type = map(any)
}

variable detail_monitoring {
  type = bool
  default = false
}