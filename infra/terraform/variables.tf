variable "aws_region" {
  description = "AWS region where the infrastructure would be deployed."
  type        = string
}

variable "project_name" {
  description = "Name of the project."
  type        = string

  validation {
    condition     = length(var.project_name) > 0
    error_message = "project_name must not be empty."
  }
}

variable "environment" {
  description = "Deployment environment."
  type        = string

  validation {
    condition     = contains(["staging", "production"], var.environment)
    error_message = "environment must be either staging or production."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for the application VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster."
  type        = string
  default     = "1.30"
}

variable "repository_owner" {
  description = "GitHub repository owner."
  type        = string
  default     = ""
}

variable "repository_name" {
  description = "GitHub repository name."
  type        = string
  default     = ""
}

variable "repository_branch" {
  description = "GitHub branch used by the CI/CD pipeline."
  type        = string
  default     = "main"
}

variable "connection_arn" {
  description = "AWS CodeConnections ARN for the GitHub repository."
  type        = string
  sensitive   = true
  default     = ""
}