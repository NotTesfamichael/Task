provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "app_assets" {
  bucket = "my-microservice-assets-${random_id.id.hex}"
}

resource "aws_iam_role" "app_s3_role" {
  name = "flask-api-s3-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRoleWithWebIdentity"
      Effect = "Allow"
      Principal = { Federated = var.oidc_arn }
    }]
  })
}

resource "aws_iam_role_policy" "s3_access" {
  name = "s3-access-policy"
  role = aws_iam_role.app_s3_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = ["s3:GetObject", "s3:PutObject"]
      Effect   = "Allow"
      Resource = "${aws_s3_bucket.app_assets.arn}/*"
    }]
  })
}