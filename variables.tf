variable "aws_region" {
  type        = string
  description = "The AWS default region"
  default     = "ap-southeast-1"
}

variable "owner" {
  type        = string
  description = "The cluster owner name"
  default     = "duongdx"
}

variable "business_division" {
  type    = string
  default = "study"
}

# Environment Variable
variable "environment" {
  description = "Environment Variable used as a prefix"
  type        = string
  default     = "dev"
}
