data "aws_iam_policy_document" "sns_kms_key_policy" {
  statement {
    sid    = "AllowAccountRootFullKmsAccess"
    effect = "Allow"

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
    }

    actions = [
      "kms:*"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "AllowCloudWatchToPublishToEncryptedSns"
    effect = "Allow"

    principals {
      type = "Service"
      identifiers = [
        "cloudwatch.amazonaws.com"
      ]
    }

    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]

    resources = ["*"]
  }
}

resource "aws_kms_key" "sns_alerts" {
  description             = "KMS key for encrypted SNS alert topic used by CloudWatch alarms."
  deletion_window_in_days = 7
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.sns_kms_key_policy.json

  tags = {
    Name = "${local.name_prefix}-sns-alerts-kms"
  }
}

resource "aws_kms_alias" "sns_alerts" {
  name          = "alias/${local.name_prefix}-sns-alerts"
  target_key_id = aws_kms_key.sns_alerts.key_id
}