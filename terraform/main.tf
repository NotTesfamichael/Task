provider "aws" {
  region = "us-east-1"
}

resource "random_id" "id" {
  byte_length = 4
}

resource "aws_s3_bucket" "app_assets" {
  bucket = "microservice-assets-${random_id.id.hex}"
}

resource "aws_iam_role" "app_s3_role" {
  name = "flask-api-s3-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_policy" "s3_access_policy" {
  name = "s3-access-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = ["s3:GetObject", "s3:PutObject"]
      Effect   = "Allow"
      Resource = "${aws_s3_bucket.app_assets.arn}/*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "s3_access_attachment" {
  role       = aws_iam_role.app_s3_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}
