variable "aws_region" {
  type        = string
  description = "The AWS default region"
  default     = "ap-southeast-1"
}

# Environment Variable
variable "environment" {
  description = "Environment Variable used as a prefix"
  type = string
  default = "dev"
}