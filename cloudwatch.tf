resource "aws_cloudwatch_metric_alarm" "lambda_dlq_visible_messages" {
  alarm_name          = "${local.name_prefix}-lambda-dlq-visible-messages"
  alarm_description   = "Triggers when failed Lambda events appear in the SQS dead-letter queue."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = 0
  period              = 60
  statistic           = "Maximum"

  namespace   = "AWS/SQS"
  metric_name = "ApproximateNumberOfMessagesVisible"

  dimensions = {
    QueueName = aws_sqs_queue.lambda_dlq.name
  }

  alarm_actions = [
    aws_sns_topic.alerts.arn
  ]

  ok_actions = [
    aws_sns_topic.alerts.arn
  ]

  treat_missing_data = "notBreaching"

  tags = {
    Name = "${local.name_prefix}-lambda-dlq-visible-messages"
  }
}