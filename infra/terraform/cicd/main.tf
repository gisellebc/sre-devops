resource "aws_ecr_repository" "backend" {
  name                = "${var.project_name}-${var.environment}/backend"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = var.tags
}

resource "aws_ecr_repository" "frontend" {
  name                 = "${var.project_name}-${var.environment}/frontend"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = var.tags
}


resource "aws_s3_bucket" "artifacts" {
  bucket_prefix = "${var.project_name}-${var.environment}-pipeline-"

  tags = var.tags
}

resource "aws_s3_bucket_versioning" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}


resource "aws_iam_role" "codebuild" {
  name = "${var.project_name}-${var.environment}-codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "codebuild.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}


resource "aws_iam_role_policy" "codebuild" {
  name = "${var.project_name}-${var.environment}-codepipeline-policy"
  role = aws_iam_role.codebuild.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]

        Resource = "*"
      },

      {
        Effect = "Allow"

        Action = [
          "ecr:GetAuthorizationToken"
        ]

        Resource = "*"
      },

      {
        Effect = "Allow"

        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart",
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer"
        ]

        Resource = [
          aws_ecr_repository.backend.arn,
          aws_ecr_repository.frontend.arn
        ]
      }
    ]
  })
}


resource "aws_codebuild_project" "validate" {
  name         = "${var.project_name}-validate"
  service_role = aws_iam_role.codebuild.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = var.build_image
    type                        = "LINUX_CONTAINER"
    privileged_mode             = true
    image_pull_credentials_type = "CODEBUILD"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "ci/buildspec-validate.yml"
  }

  tags = var.tags
}


resource "aws_codebuild_project" "build" {
  name         = "${var.project_name}-build"
  service_role = aws_iam_role.codebuild.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_MEDIUM"
    image                       = var.build_image
    type                        = "LINUX_CONTAINER"
    privileged_mode             = true
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "BACKEND_REPOSITORY"
      value = aws_ecr_repository.backend.repository_url
    }

    environment_variable {
      name  = "FRONTEND_REPOSITORY"
      value = aws_ecr_repository.frontend.repository_url
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "ci/buildspec-build.yml"
  }

  tags = var.tags
}


resource "aws_codebuild_project" "staging" {
  name         = "${var.project_name}-staging"
  service_role = aws_iam_role.codebuild.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = var.build_image
    type                        = "LINUX_CONTAINER"
    privileged_mode             = true
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "DEPLOY_ENVIRONMENT"
      value = "staging"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "ci/buildspec-deploy.yml"
  }

  tags = var.tags
}


resource "aws_codebuild_project" "production" {
  name         = "${var.project_name}-production"
  service_role = aws_iam_role.codebuild.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = var.build_image
    type                        = "LINUX_CONTAINER"
    privileged_mode             = true
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "DEPLOY_ENVIRONMENT"
      value = "production"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "ci/buildspec-deploy.yml"
  }

  tags = var.tags
}


resource "aws_iam_role" "codepipeline" {
  name = "${var.project_name}-${var.environment}-codepipeline-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "codepipeline.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}


resource "aws_iam_role_policy" "codepipeline" {
  name = "${var.project_name}-codepipeline-policy"
  role = aws_iam_role.codepipeline.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject",
          "s3:GetBucketVersioning"
        ]

        Resource = [
          aws_s3_bucket.artifacts.arn,
          "${aws_s3_bucket.artifacts.arn}/*"
        ]
      },

      {
        Effect = "Allow"

        Action = [
          "codebuild:StartBuild",
          "codebuild:BatchGetBuilds"
        ]

        Resource = [
          aws_codebuild_project.validate.arn,
          aws_codebuild_project.build.arn,
          aws_codebuild_project.staging.arn,
          aws_codebuild_project.production.arn
        ]
      },

      {
        Effect = "Allow"

        Action = [
          "codeconnections:UseConnection"
        ]

        Resource = var.connection_arn
      }
    ]
  })
}


resource "aws_codepipeline" "main" {
  name     = "${var.project_name}-${var.environment}-pipeline"
  role_arn = aws_iam_role.codepipeline.arn

  artifact_store {
    location = aws_s3_bucket.artifacts.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "GitHub"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source"]

      configuration = {
        ConnectionArn    = var.connection_arn
        FullRepositoryId = "${var.repository_owner}/${var.repository_name}"
        BranchName       = var.repository_branch
      }
    }
  }

  stage {
    name = "Validate"

    action {
      name            = "Validate"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source"]

      configuration = {
        ProjectName = aws_codebuild_project.validate.name
      }
    }
  }

  stage {
    name = "Build"

    action {
      name            = "BuildAndScan"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source"]

      configuration = {
        ProjectName = aws_codebuild_project.build.name
      }
    }
  }

  stage {
    name = "Staging"

    action {
      name            = "DeployStaging"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source"]

      configuration = {
        ProjectName = aws_codebuild_project.staging.name
      }
    }
  }

  stage {
    name = "ProductionApproval"

    action {
      name     = "ApproveProduction"
      category = "Approval"
      owner    = "AWS"
      provider = "Manual"
      version  = "1"

      configuration = {
        CustomData = "Review the staging deployment before promoting to production."
      }
    }
  }

  stage {
    name = "Production"

    action {
      name            = "DeployProduction"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source"]

      configuration = {
        ProjectName = aws_codebuild_project.production.name
      }
    }
  }

  tags = var.tags
}