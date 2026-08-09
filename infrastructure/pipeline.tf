# OIDC provider for GitHub Actions
resource "aws_iam_openid_connect_provider" "github" {
  url = local.github_oidc_url
  client_id_list = [local.github_oidc_client_id]
  thumbprint_list = [local.github_oidc_thumbprint] 
}

# IAM role assumed by GitHub Action workflow.
resource "aws_iam_role" "pipeline_oidc" {
  name = "pipeline-oidc-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub" = [
              "${var.github_repository_with_id}:ref:refs/heads/${var.github_repository_branch}",
              "${var.github_repository_with_id}:environment:production",
              // Legacy claim format for GitHub Actions OIDC.
              "repo:${var.github_repository}:ref:refs/heads/${var.github_repository_branch}",
              "repo:${var.github_repository}:environment:production",
            ]
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "pipeline_admin" {
  role       = aws_iam_role.pipeline_oidc.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}