
variable "aws_region" {
  description = "AWS region where bootstrap resources will be created."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project identifier used for resource naming and tagging."
  type        = string
  default     = "aws-iot-device-monitoring"
}

variable "github_repository" {
  description = "Authorized GitHub repository in owner/repository format."
  type        = string
  default     = "enriquehugo20/aws-iot-device-monitoring-platform"
}

variable "github_branch" {
  description = "GitHub branch authorized to deploy infrastructure."
  type        = string
  default     = "main"
}

variable "state_bucket_prefix" {
  description = "Prefix used to generate the Terraform state bucket name."
  type        = string
  default     = "aws-iot-device-monitoring-tfstate"
}
