# Lab 3 Step 1 — Architecture Inventory

## Manual Lab 2 to Terraform Translation

| Manual AWS Component | Purpose | Terraform Resource |
|---|---|---|
| S3 bucket | Stores uploaded files and triggers processing | aws_s3_bucket |
| S3 event notification | Invokes Lambda on upload | aws_s3_bucket_notification |
| Lambda function | Processes uploaded file metadata | aws_lambda_function |
| Lambda execution role | Allows Lambda to access AWS services | aws_iam_role |
| IAM permissions | Least-privilege access for Lambda | aws_iam_policy |
| DynamoDB table | Stores file metadata | aws_dynamodb_table |
| SQS DLQ | Captures failed async processing events | aws_sqs_queue |
| CloudWatch Logs | Stores Lambda execution logs | aws_cloudwatch_log_group |
| CloudWatch Alarm | Detects Lambda errors | aws_cloudwatch_metric_alarm |
| SNS Topic | Sends failure alerts | aws_sns_topic |

## First Interview Explanation

I manually built a serverless file-processing pipeline using S3, Lambda, DynamoDB, SQS, CloudWatch, and SNS. For Lab 3, I am rebuilding that same architecture with Terraform so the infrastructure is repeatable, version-controlled, and closer to a real production deployment workflow.

