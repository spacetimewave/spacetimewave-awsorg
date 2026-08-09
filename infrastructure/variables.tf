# --------------------------------------------- #
# --------------- AWS + OpenTofu -------------- #
# --------------------------------------------- #
variable "aws_account_id" {}

variable "aws_region" {
  default = "eu-west-1"
}

variable "otf_state_s3_bucket_name" {}

variable "otf_state_s3_file_name" {}

variable "github_repository" {
  description = "GitHub repository allowed to assume the OIDC pipeline role."
}

variable "github_repository_with_id" {
  description = "GitHub repository immutable subject claim prefix for OIDC. Check repository settings > Actions > OIDC: \"org@org_id/repo@repo_id\"."
}

variable "github_repository_branch" {}

# --------------------------------------------- #
# ------------------ Project ------------------ #
# --------------------------------------------- #

variable "root_account_email" {
  description = "Root-user email for the root AWS account. Must be globally unique across all AWS accounts."
}

variable "julmosport_account_email" {
  description = "Root-user email for julmosport AWS accounts. Must be globally unique across all AWS accounts."
}

