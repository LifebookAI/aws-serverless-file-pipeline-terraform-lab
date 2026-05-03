data "aws_caller_identity" "current" {}

locals {
  name_prefix        = "${var.project_name}-${var.environment}"
  upload_bucket_name = "${local.name_prefix}-${data.aws_caller_identity.current.account_id}-uploads"
}

resource "aws_s3_bucket" "uploads" {
  bucket = local.upload_bucket_name

  tags = {
    Name = local.upload_bucket_name
  }
}

resource "aws_s3_bucket_public_access_block" "uploads" {
  bucket = aws_s3_bucket.uploads.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "uploads" {
  bucket = aws_s3_bucket.uploads.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "uploads" {
  bucket = aws_s3_bucket.uploads.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}