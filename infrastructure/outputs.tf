output "pipeline_oidc_role_arn" {
  value       = aws_iam_role.pipeline_oidc.arn
  description = "ARN of the IAM role assumed by GitHub Action workflow."
}