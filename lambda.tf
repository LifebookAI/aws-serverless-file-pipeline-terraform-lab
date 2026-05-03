data "archive_file" "lambda_package" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/src"
  output_path = "${path.module}/lambda_package.zip"
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${local.lambda_function_name}"
  retention_in_days = 14

  tags = {
    Name = "/aws/lambda/${local.lambda_function_name}"
  }
}

resource "aws_lambda_function" "file_processor" {
  function_name = local.lambda_function_name
  role          = aws_iam_role.lambda_exec.arn
  runtime       = "python3.12"
  handler       = "handler.lambda_handler"

  filename         = data.archive_file.lambda_package.output_path
  source_code_hash = data.archive_file.lambda_package.output_base64sha256

  timeout     = 30
  memory_size = 128

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.file_metadata.name
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.lambda,
    aws_iam_role_policy_attachment.lambda_exec
  ]

  tags = {
    Name = local.lambda_function_name
  }
}