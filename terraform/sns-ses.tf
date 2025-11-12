# SNS Topic for Pipeline Notifications
resource "aws_sns_topic" "pipeline_notifications" {
  name = "${var.project_name}-pipeline-notifications"

  tags = {
    Name = "${var.project_name}-pipeline-notifications"
  }
}

# SNS Topic Subscription (Email)
resource "aws_sns_topic_subscription" "pipeline_email" {
  topic_arn = aws_sns_topic.pipeline_notifications.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

# CloudWatch Event Rule for Pipeline State Changes
resource "aws_cloudwatch_event_rule" "pipeline_state_change" {
  name        = "${var.project_name}-pipeline-state-change"
  description = "Capture pipeline state changes"

  event_pattern = jsonencode({
    source      = ["aws.codepipeline"]
    detail-type = ["CodePipeline Pipeline Execution State Change"]
    detail = {
      pipeline = [aws_codepipeline.main.name]
      state    = ["FAILED", "SUCCEEDED"]
    }
  })

  tags = {
    Name = "${var.project_name}-pipeline-event-rule"
  }
}

# CloudWatch Event Target for SNS
resource "aws_cloudwatch_event_target" "sns" {
  rule      = aws_cloudwatch_event_rule.pipeline_state_change.name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.pipeline_notifications.arn

  input_transformer {
    input_paths = {
      pipeline = "$.detail.pipeline"
      state    = "$.detail.state"
      time     = "$.time"
    }
    input_template = "\"Pipeline <pipeline> has <state> at <time>\""
  }
}

# SNS Topic Policy to allow CloudWatch Events
resource "aws_sns_topic_policy" "pipeline_notifications" {
  arn = aws_sns_topic.pipeline_notifications.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Action   = "SNS:Publish"
        Resource = aws_sns_topic.pipeline_notifications.arn
      }
    ]
  })
}

# CloudWatch Event Rule for CodeBuild State Changes
resource "aws_cloudwatch_event_rule" "codebuild_state_change" {
  name        = "${var.project_name}-codebuild-state-change"
  description = "Capture CodeBuild state changes"

  event_pattern = jsonencode({
    source      = ["aws.codebuild"]
    detail-type = ["CodeBuild Build State Change"]
    detail = {
      project-name = [aws_codebuild_project.main.name]
      build-status = ["FAILED", "SUCCEEDED"]
    }
  })

  tags = {
    Name = "${var.project_name}-codebuild-event-rule"
  }
}

# CloudWatch Event Target for CodeBuild to SNS
resource "aws_cloudwatch_event_target" "codebuild_sns" {
  rule      = aws_cloudwatch_event_rule.codebuild_state_change.name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.pipeline_notifications.arn

  input_transformer {
    input_paths = {
      project = "$.detail.project-name"
      status  = "$.detail.build-status"
      time    = "$.time"
    }
    input_template = "\"CodeBuild project <project> has <status> at <time>\""
  }
}

# SES Email Identity (requires verification)
resource "aws_ses_email_identity" "notification_email" {
  email = var.notification_email
}

# CloudWatch Alarm for Failed Builds
resource "aws_cloudwatch_metric_alarm" "build_failures" {
  alarm_name          = "${var.project_name}-build-failures"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "FailedBuilds"
  namespace           = "AWS/CodeBuild"
  period              = "300"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "This metric monitors CodeBuild failures"
  alarm_actions       = [aws_sns_topic.pipeline_notifications.arn]

  dimensions = {
    ProjectName = aws_codebuild_project.main.name
  }

  tags = {
    Name = "${var.project_name}-build-failures-alarm"
  }
}
