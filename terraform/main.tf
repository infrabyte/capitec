
data "aws_caller_identity" "current" {}

resource "aws_ecr_repository" "app" {

  name                 = var.project_name
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Project     = var.project_name
    Environment = "assessment"
    ManagedBy   = "Terraform"
  }
}

resource "aws_s3_bucket" "artifacts" {

  bucket = "${var.project_name}-artifacts-${data.aws_caller_identity.current.account_id}"

  tags = {
    Project     = var.project_name
    Environment = "assessment"
    ManagedBy   = "Terraform"
  }
}

resource "aws_s3_bucket_versioning" "artifacts" {

  bucket = aws_s3_bucket.artifacts.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "artifacts" {

  bucket = aws_s3_bucket.artifacts.id

  rule {

    apply_server_side_encryption_by_default {

      sse_algorithm = "AES256"

    }
  }
}

resource "aws_s3_bucket_public_access_block" "artifacts" {

  bucket = aws_s3_bucket.artifacts.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_iam_user" "ci_deploy" {

  name = "${var.project_name}-ci-deploy"

  tags = {
    Project     = var.project_name
    Environment = "assessment"
    ManagedBy   = "Terraform"
  }
}

resource "aws_iam_policy" "ci_deploy" {

  name        = "${var.project_name}-ci-deploy"
  description = "Least privilege policy for CI/CD"

  policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {
        Sid    = "ECRAccess"
        Effect = "Allow"

        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:DescribeRepositories",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart",
          "ecr:BatchGetImage"
        ]

        Resource = "*"
      },

      {
        Sid    = "S3Artifacts"
        Effect = "Allow"

        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]

        Resource = [
          "${aws_s3_bucket.artifacts.arn}/*"
        ]
      },

      {
        Sid    = "S3List"
        Effect = "Allow"

        Action = [
          "s3:ListBucket"
        ]

        Resource = aws_s3_bucket.artifacts.arn
      }

    ]
  })
}

resource "aws_iam_user_policy_attachment" "ci_deploy" {

  user       = aws_iam_user.ci_deploy.name
  policy_arn = aws_iam_policy.ci_deploy.arn
}

resource "aws_iam_access_key" "ci_deploy" {

  user = aws_iam_user.ci_deploy.name
}

resource "aws_secretsmanager_secret" "ci_credentials" {

  name = "${var.project_name}-ci-credentials"

  tags = {
    Project     = var.project_name
    Environment = "assessment"
    ManagedBy   = "Terraform"
  }
}

resource "aws_secretsmanager_secret_version" "ci_credentials" {

  secret_id = aws_secretsmanager_secret.ci_credentials.id

  secret_string = jsonencode({
    access_key_id     = aws_iam_access_key.ci_deploy.id
    secret_access_key = aws_iam_access_key.ci_deploy.secret
  })
}