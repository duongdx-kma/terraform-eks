
variable "vpc_id" {
  description = "The vpc_id"
  type = string
}

variable bastion_host_ingress {
  description = "The ingress for bastion host"
  type = list(object({
    from_port = number
    to_port = number
    protocol =  string
    description = string
    cidr_blocks = string
  }))
}

variable tags {
  type = map(any)
}
