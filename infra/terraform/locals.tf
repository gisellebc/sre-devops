locals {
  name = "${var.project_name}-${var.environment}"

  availability_zones = [
    "${var.aws_region}a",
    "${var.aws_region}b",
    "${var.aws_region}c"
  ]

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}