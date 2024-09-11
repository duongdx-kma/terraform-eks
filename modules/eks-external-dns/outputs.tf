output "external_dns_iam_policy_arn" {
  value = aws_iam_policy.external_dns_iam_policy.arn
}

output "external_dns_iam_role_arn" {
  description = "External DNS IAM Role ARN"
  value       = aws_iam_role.external_dns_iam_role.arn
}


# Helm Release Outputs
output "external_dns_helm_metadata" {
  description = "Metadata Block outlining status of the deployed release."
  value = helm_release.external_dns.metadata
}