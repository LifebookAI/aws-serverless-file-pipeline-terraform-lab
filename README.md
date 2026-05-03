# AWS Serverless File Pipeline — Terraform Lab

## Overview

This project rebuilds my manually created AWS serverless file-processing pipeline using Terraform.

The goal was to convert a working manual AWS architecture into repeatable Infrastructure as Code while practicing real cloud engineering skills: IAM, event-driven design, Lambda packaging, Terraform state, monitoring, alerting, encryption, and troubleshooting.

## Architecture

```text
File upload
→ Amazon S3
→ S3 ObjectCreated event
→ AWS Lambda
→ Amazon DynamoDB metadata table

Failure path:
Lambda async failure
→ SQS dead-letter queue
→ CloudWatch alarm
→ SNS topic
→ Email notification
```

## AWS Services Used

| Service | Purpose |
|---|---|
| Amazon S3 | Stores uploaded files and emits ObjectCreated events |
| AWS Lambda | Processes S3 events and extracts object metadata |
| Amazon DynamoDB | Stores structured file metadata |
| IAM | Provides least-privilege Lambda execution permissions |
| Amazon SQS | Stores failed Lambda events in a dead-letter queue |
| Amazon CloudWatch | Stores Lambda logs and monitors DLQ metrics |
| Amazon SNS | Sends alert notifications |
| AWS KMS | Encrypts the SNS alert topic with a customer-managed key |
| Terraform | Defines and manages AWS infrastructure as code |

## What the Pipeline Does

When a file is uploaded to the S3 bucket, S3 sends an event to Lambda. Lambda reads the bucket name and object key from the event, calls S3 to inspect object metadata, and writes a metadata record to DynamoDB.

The DynamoDB record includes:

- File ID
- Bucket name
- Object key
- File size
- Content type
- ETag
- Processing timestamp

## Reliability and Failure Handling

The Lambda function is configured with an SQS dead-letter queue. If asynchronous Lambda processing fails after retries are exhausted, the failed event is preserved in SQS for troubleshooting or replay.

A CloudWatch alarm monitors the DLQ using:

```text
Metric: ApproximateNumberOfMessagesVisible
Namespace: AWS/SQS
Threshold: > 0
```

If failed messages appear in the DLQ, CloudWatch publishes to SNS.

## Alerting and Encryption Fix

The SNS alert topic is encrypted using a customer-managed KMS key.

During testing, direct SNS email delivery worked, but CloudWatch alarm actions initially failed to publish to the encrypted SNS topic. I fixed this by replacing the AWS-managed SNS key with a customer-managed KMS key and explicitly allowing `cloudwatch.amazonaws.com` to use the key for SNS publishing.

This preserved encryption while fixing the CloudWatch-to-SNS alert path.

## Terraform Concepts Practiced

- Provider configuration
- Variables
- Local values
- Data sources
- Resource dependencies
- Lambda zip packaging with the archive provider
- Least-privilege IAM policies
- Terraform plan/apply workflow
- State inspection
- Drift checks
- Safe handling of local variables with `terraform.tfvars`
- Git checkpoints after each validated layer

## Security Practices

- S3 public access blocked
- S3 encryption enabled
- S3 versioning enabled
- DynamoDB encryption enabled
- DynamoDB point-in-time recovery enabled
- Lambda uses least-privilege IAM
- SNS encrypted with customer-managed KMS
- Real alert email stored in local `terraform.tfvars`, not committed to Git
- Terraform state and local artifacts ignored by Git

## Validation Performed

I validated the full success path:

```text
S3 upload → Lambda invocation → DynamoDB metadata record
```

I also validated the alert path:

```text
CloudWatch alarm → encrypted SNS topic → Email notification
```

Troubleshooting evidence included checking:

- Terraform plan output
- Terraform state
- AWS CLI resource verification
- DynamoDB scan results
- Lambda logs
- CloudWatch alarm history
- SNS direct publish test
- KMS key policy behavior

## Key Learning Outcomes

This lab taught me how to move from manually built AWS infrastructure to repeatable Terraform-managed infrastructure.

The most important lessons were:

1. Terraform `plan` previews changes, while `apply` changes AWS.
2. Terraform state is Terraform's memory of real infrastructure.
3. IAM roles define who a service can act as, while policies define what it can do.
4. S3 needs both a bucket notification and Lambda resource permission to invoke Lambda.
5. DLQs preserve failed async events but do not fix errors automatically.
6. CloudWatch detects alarm conditions; SNS delivers notifications.
7. Encrypted SNS topics can require customer-managed KMS permissions for publishing services like CloudWatch.

## Resume Bullet

Built a Terraform-managed AWS serverless file-processing pipeline using S3, Lambda, DynamoDB, SQS DLQ, CloudWatch alarms, SNS email alerts, IAM least privilege, and KMS encryption; validated end-to-end event processing, failure handling, alerting, and infrastructure drift detection.

## Cleanup

To destroy the lab resources:

```powershell
terraform destroy
```

Before destroying, empty the S3 bucket if Terraform cannot delete it due to existing objects.

## Status

- Terraform foundation complete
- S3 upload bucket deployed
- DynamoDB metadata table deployed
- Lambda IAM role and policy deployed
- Lambda function deployed
- S3 trigger connected
- End-to-end file processing tested
- SQS DLQ attached
- CloudWatch DLQ alarm deployed
- SNS email alerting configured
- Customer-managed KMS fix applied for encrypted alert publishing
