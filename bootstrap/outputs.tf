
output "state_bucket_name" {
  description = "Terraform remote state bucket name."
  value       = aws_s3_bucket.terraform_state.id
}

output "state_bucket_arn" {
  description = "Terraform remote state bucket ARN."
  value       = aws_s3_bucket.terraform_state.arn
}

output "github_actions_role_arn" {
  description = "IAM role ARN for GitHub Actions."
  value       = aws_iam_role.github_actions.arn
}

output "github_oidc_provider_arn" {
  description = "GitHub OIDC provider ARN."
  value       = aws_iam_openid_connect_provider.github.arn
}

output "aws_account_id" {
  description = "AWS account ID."
  value       = data.aws_caller_identity.current.account_id
}
