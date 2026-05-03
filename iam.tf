locals {
  lambda_function_name = "${local.name_prefix}-file-processor"
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_exec" {
  name               = "${local.name_prefix}-lambda-exec-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json

  tags = {
    Name = "${local.name_prefix}-lambda-exec-role"
  }
}

data "aws_iam_policy_document" "lambda_permissions" {
  statement {
    sid    = "AllowReadUploadedFiles"
    effect = "Allow"

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.uploads.arn}/*"
    ]
  }

  statement {
    sid    = "AllowWriteMetadata"
    effect = "Allow"

    actions = [
      "dynamodb:PutItem"
    ]

    resources = [
      aws_dynamodb_table.file_metadata.arn
    ]
  }

  statement {
    sid    = "AllowSendFailedEventsToDlq"
    effect = "Allow"

    actions = [
      "sqs:SendMessage"
    ]

    resources = [
      aws_sqs_queue.lambda_dlq.arn
    ]
  }

  statement {
    sid    = "AllowWriteCloudWatchLogs"
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${local.lambda_function_name}:*"
    ]
  }
}

resource "aws_iam_policy" "lambda_exec" {
  name        = "${local.name_prefix}-lambda-exec-policy"
  description = "Least-privilege permissions for the file processing Lambda."
  policy      = data.aws_iam_policy_document.lambda_permissions.json

  tags = {
    Name = "${local.name_prefix}-lambda-exec-policy"
  }
}

resource "aws_iam_role_policy_attachment" "lambda_exec" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_exec.arn
}