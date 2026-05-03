# Architecture Map

## AWS Serverless File Pipeline — Terraform Lab

```mermaid
flowchart LR
    User[User uploads file] --> S3[Amazon S3 Upload Bucket]

    S3 -->|ObjectCreated event| Lambda[AWS Lambda File Processor]
    Lambda -->|head_object| S3
    Lambda -->|put_item metadata| DDB[Amazon DynamoDB File Metadata Table]

    Lambda -->|failed async events| DLQ[Amazon SQS Dead-Letter Queue]
    DLQ -->|visible messages > 0| CW[Amazon CloudWatch Alarm]
    CW -->|alarm action| SNS[Amazon SNS Alert Topic]
    SNS -->|email notification| Email[founder@uselifebook.ai]

    KMS[AWS KMS Customer-Managed Key] -->|encrypts| SNS

    TF[Terraform] --> S3
    TF --> Lambda
    TF --> DDB
    TF --> DLQ
    TF --> CW
    TF --> SNS
    TF --> KMS

    GHA[GitHub Actions] -->|OIDC assume role| IAM[IAM Role]
    IAM -->|plan-only access| TFState[S3 Remote Terraform State]
    TF --> TFState
```

## Success Path

```text
S3 upload
→ S3 ObjectCreated event
→ Lambda invocation
→ S3 object metadata read
→ DynamoDB metadata record created
```

## Failure / Alert Path

```text
Lambda async failure
→ SQS DLQ
→ CloudWatch alarm
→ Encrypted SNS topic
→ Email notification
```

## Infrastructure as Code Path

```text
GitHub push / PR
→ GitHub Actions Terraform CI
→ GitHub Actions OIDC role assumption
→ Terraform init with S3 remote backend
→ Terraform plan against deployed AWS resources
```

## Security Notes

- Lambda uses least-privilege IAM.
- S3 public access is blocked.
- S3 and DynamoDB encryption are enabled.
- SNS uses a customer-managed KMS key.
- CloudWatch is explicitly allowed to use the SNS KMS key.
- Terraform state is stored remotely in S3 with locking enabled.
- GitHub Actions uses OIDC instead of long-lived AWS keys.
