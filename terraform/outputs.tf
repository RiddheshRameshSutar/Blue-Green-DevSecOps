output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "alb_dns_name" {
  description = "Application Load Balancer DNS name"
  value       = aws_lb.main.dns_name
}

output "alb_url" {
  description = "Application URL"
  value       = "http://${aws_lb.main.dns_name}"
}

output "blue_instance_ids" {
  description = "Blue environment EC2 instance IDs"
  value       = aws_instance.blue[*].id
}

output "green_instance_ids" {
  description = "Green environment EC2 instance IDs"
  value       = aws_instance.green[*].id
}

output "sonarqube_public_ip" {
  description = "SonarQube server public IP"
  value       = aws_instance.sonarqube.public_ip
}

output "sonarqube_url" {
  description = "SonarQube URL"
  value       = "http://${aws_instance.sonarqube.public_ip}:9000"
}

output "codepipeline_name" {
  description = "CodePipeline name"
  value       = aws_codepipeline.main.name
}

output "codebuild_project_name" {
  description = "CodeBuild project name"
  value       = aws_codebuild_project.main.name
}

output "codedeploy_application_name" {
  description = "CodeDeploy application name"
  value       = aws_codedeploy_app.main.name
}

output "s3_artifacts_bucket" {
  description = "S3 bucket for artifacts"
  value       = aws_s3_bucket.artifacts.id
}

output "s3_reports_bucket" {
  description = "S3 bucket for security reports"
  value       = aws_s3_bucket.reports.id
}

output "blue_target_group_arn" {
  description = "Blue target group ARN"
  value       = aws_lb_target_group.blue.arn
}

output "green_target_group_arn" {
  description = "Green target group ARN"
  value       = aws_lb_target_group.green.arn
}
