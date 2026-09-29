variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where EKS will be deployed."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for EKS."
  type        = list(string)
}

variable "tags" {
  description = "Tags applied to EKS resources."
  type        = map(string)
  default     = {}
}