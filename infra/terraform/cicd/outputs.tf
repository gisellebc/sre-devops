output "pipeline_name" {
  description = "Name of the CodePipeline."
  value       = aws_codepipeline.main.name
}

output "pipeline_arn" {
  description = "ARN of the CodePipeline."
  value       = aws_codepipeline.main.arn
}

output "backend_repository_name" {
  description = "Name of the backend ECR repository."
  value       = aws_ecr_repository.backend.name
}

output "backend_repository_url" {
  description = "URL of the backend ECR repository."
  value       = aws_ecr_repository.backend.repository_url
}

output "frontend_repository_name" {
  description = "Name of the frontend ECR repository."
  value       = aws_ecr_repository.frontend.name
}

output "frontend_repository_url" {
  description = "URL of the frontend ECR repository."
  value       = aws_ecr_repository.frontend.repository_url
}

output "validate_project_name" {
  description = "CodeBuild validation project."
  value       = aws_codebuild_project.validate.name
}

output "build_project_name" {
  description = "CodeBuild image build project."
  value       = aws_codebuild_project.build.name
}

output "staging_project_name" {
  description = "CodeBuild staging project."
  value       = aws_codebuild_project.staging.name
}

output "production_project_name" {
  description = "CodeBuild production project."
  value       = aws_codebuild_project.production.name
}

output "artifact_bucket_name" {
  description = "S3 bucket used for CodePipeline artifacts."
  value       = aws_s3_bucket.artifacts.bucket
}