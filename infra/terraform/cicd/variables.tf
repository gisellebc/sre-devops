variable "project_name" {
  description = "Name used as the prefix for CI/CD resources."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string

  validation {
    condition     = contains(["staging", "production"], var.environment)
    error_message = "environment must be either staging or production."
  }
}

variable "repository_owner" {
  description = "GitHub repository owner."
  type        = string
}

variable "repository_name" {
  description = "GitHub repository name."
  type        = string
}

variable "repository_branch" {
  description = "GitHub branch used by CodePipeline."
  type        = string
  default     = "main"
}

variable "connection_arn" {
  description = "AWS CodeConnections ARN for the GitHub repository."
  type        = string
  sensitive   = true
  default     = ""
}

variable "build_image" {
  description = "CodeBuild Docker image."
  type        = string
  default     = "aws/codebuild/standard:7.0"
}

variable "tags" {
  description = "Tags applied to CI/CD resources."
  type        = map(string)
  default     = {}
}