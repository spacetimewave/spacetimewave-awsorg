# # OIDC provider for GitHub Actions
# resource "aws_iam_openid_connect_provider" "github" {
#   url = "https://token.actions.githubusercontent.com"
#   client_id_list = ["sts.amazonaws.com"]
#   thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"] # GitHub's thumbprint
# }

# # IAM role for CI/CD pipelines
# resource "aws_iam_role" "pipeline_oidc" {
#   name = "pipeline-oidc-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#         {
#         Effect = "Allow"
#         Principal = {
#             Federated = aws_iam_openid_connect_provider.github.arn
#         }
#         Action = "sts:AssumeRoleWithWebIdentity"
#         Condition = {
#             StringLike = {
#             "token.actions.githubusercontent.com:sub" = [
#                 "repo:cybertechcorp/montajes-lucho:ref:refs/heads/*",
#                 "repo:cybertechcorp/montajes-lucho:environment:production"
#             ]
#             }
#         }
#         }
#     ]
#   })
# }

# # Infrastructure Pipeline: Attach AdministratorAccess for full control over resources 
# resource "aws_iam_role_policy_attachment" "pipeline_admin" {
#   role       = aws_iam_role.pipeline_oidc.name
#   policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
# }

# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Sid": "OrganizationsFullAccess",
#       "Effect": "Allow",
#       "Action": "organizations:*",
#       "Resource": "*"
#     },
#     {
#       "Sid": "IAMFullAccessForOrgManagement",
#       "Effect": "Allow",
#       "Action": [
#         "iam:CreateRole",
#         "iam:DeleteRole",
#         "iam:GetRole",
#         "iam:UpdateRole",
#         "iam:PutRolePolicy",
#         "iam:DeleteRolePolicy",
#         "iam:AttachRolePolicy",
#         "iam:DetachRolePolicy",
#         "iam:PassRole",
#         "iam:CreatePolicy",
#         "iam:DeletePolicy",
#         "iam:GetPolicy",
#         "iam:GetPolicyVersion",
#         "iam:List*",
#         "iam:Tag*",
#         "iam:Untag*"
#       ],
#       "Resource": "*"
#     },
#     {
#       "Sid": "S3BackendStateAccess",
#       "Effect": "Allow",
#       "Action": [
#         "s3:ListBucket"
#       ],
#       "Resource": "arn:aws:s3:::YOUR_STATE_BUCKET"
#     },
#     {
#       "Sid": "S3BackendObjectAccess",
#       "Effect": "Allow",
#       "Action": [
#         "s3:GetObject",
#         "s3:PutObject",
#         "s3:DeleteObject"
#       ],
#       "Resource": "arn:aws:s3:::YOUR_STATE_BUCKET/*"
#     }
#   ]
# }