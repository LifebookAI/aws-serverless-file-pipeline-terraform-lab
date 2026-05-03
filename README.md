# AWS Serverless File Pipeline — Terraform Lab

## Goal

Rebuild my manual AWS Serverless File Pipeline lab using Terraform and GitHub Actions.

This lab converts a manually built AWS architecture into repeatable Infrastructure as Code.

## Original Manual Lab

Source repo:
https://github.com/LifebookAI/aws-serverless-file-pipeline-lab

## Architecture We Are Rebuilding

S3 upload bucket
→ S3 event notification
→ Lambda function
→ DynamoDB metadata table
→ CloudWatch logs
→ CloudWatch alarm
→ SNS alert topic
→ SQS dead-letter queue for failures

## What I Need To Understand

### S3
- Stores uploaded files.
- Sends an event when a new object is created.

### Lambda
- Runs code automatically when S3 receives a file.
- Reads file metadata.
- Writes metadata into DynamoDB.

### DynamoDB
- Stores file metadata.
- Serverless NoSQL database.

### IAM
- Gives Lambda only the permissions it needs.
- Lambda needs permission to read S3, write DynamoDB, write logs, and use DLQ if configured.

### SQS DLQ
- Stores failed Lambda events.
- Helps troubleshoot processing failures.

### CloudWatch
- Stores Lambda logs.
- Tracks errors and metrics.
- Triggers alarms.

### SNS
- Sends alerts when something goes wrong.

## Terraform Resources We Will Eventually Create

- aws_s3_bucket
- aws_lambda_function
- aws_iam_role
- aws_iam_policy
- aws_iam_role_policy_attachment
- aws_dynamodb_table
- aws_sqs_queue
- aws_sns_topic
- aws_cloudwatch_metric_alarm
- aws_lambda_permission
- aws_s3_bucket_notification

## Learning Rule

Before writing each Terraform resource, I should be able to answer:

1. What does this resource do?
2. Why does the pipeline need it?
3. What permissions does it require?
4. What would break if it were missing?
5. How would I troubleshoot it?

