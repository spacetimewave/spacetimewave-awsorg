output "pipeline_oidc_role_arn" {
  value       = aws_iam_role.pipeline_oidc.arn
  description = "ARN of the IAM role assumed by GitHub Action workflow."
}

output "organization_root_id" {
  value       = aws_organizations_organization.this.roots[0].id
  description = "ID of the AWS Organization root."
}

output "workloads_ou_id" {
  value       = aws_organizations_organizational_unit.workloads.id
  description = "ID of the Workloads OU."
}

output "workloads_external_ou_id" {
  value       = aws_organizations_organizational_unit.workloads_external.id
  description = "ID of the Workloads/External OU."
}

output "workloads_internal_ou_id" {
  value       = aws_organizations_organizational_unit.workloads_internal.id
  description = "ID of the Workloads/Internal OU."
}

output "customers_ou_id" {
  value       = aws_organizations_organizational_unit.customers.id
  description = "ID of the Customers OU."
}