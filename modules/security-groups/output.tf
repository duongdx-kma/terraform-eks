output "bastion_sg_arn" {
  description = "The ARN of the security group"
  value       = module.bastion_sg.security_group_arn
}

output "bastion_sg_id" {
  description = "The ID of the security group"
  value       = module.bastion_sg.security_group_id
}

output "bastion_sg_vpc_id" {
  description = "The VPC ID"
  value       = module.bastion_sg.security_group_vpc_id
}

output "bastion_sg_owner_id" {
  description = "The owner ID"
  value       = module.bastion_sg.security_group_owner_id
}

output "bastion_sg_name" {
  description = "The name of the security group"
  value       = module.bastion_sg.security_group_name
}

output "bastion_sg_description" {
  description = "The description of the security group"
  value       = module.bastion_sg.security_group_description
}