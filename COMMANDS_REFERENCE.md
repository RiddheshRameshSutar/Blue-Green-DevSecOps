# 📝 Quick Commands Reference

Essential commands for managing your Blue-Green DevSecOps infrastructure.

## 🚀 Initial Setup

```bash
# Create EC2 key pair
cd terraform
chmod +x create-key-pair.sh
./create-key-pair.sh

# Configure Terraform variables
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars

# Initialize and deploy
terraform init
terraform plan
terraform apply

# Setup Parameter Store
chmod +x setup-parameters.sh
./setup-parameters.sh
```

## 📊 Get Infrastructure Information

```bash
# All outputs
terraform output

# Specific outputs
terraform output alb_url
terraform output sonarqube_url
terraform output blue_instance_ids
terraform output green_instance_ids

# Export to environment variables
export ALB_URL=$(terraform output -raw alb_dns_name)
export SONARQUBE_IP=$(terraform output -raw sonarqube_public_ip)
export BLUE_TG=$(terraform output -raw blue_target_group_arn)
export GREEN_TG=$(terraform output -raw green_target_group_arn)
```

## 🔐 AWS Systems Manager Parameter Store

```bash
# List all parameters
aws ssm describe-parameters --region ap-south-1

# Get parameter value (non-secure)
aws ssm get-parameter \
  --name /cicd/docker-registry/url \
  --region ap-south-1

# Get secure parameter value
aws ssm get-parameter \
  --name /cicd/docker-credentials/password \
  --with-decryption \
  --region ap-south-1

# Create/Update parameter
aws ssm put-parameter \
  --name /cicd/sonar/sonar-token \
  --value "YOUR_TOKEN" \
  --type SecureString \
  --region ap-south-1 \
  --overwrite

# Delete parameter
aws ssm delete-parameter \
  --name /cicd/sonar/sonar-token \
  --region ap-south-1
```

## 🔄 CodePipeline Management

```bash
# Get pipeline status
aws codepipeline get-pipeline-state \
  --name blue-green-devsecops-pipeline \
  --region ap-south-1

# List pipeline executions
aws codepipeline list-pipeline-executions \
  --pipeline-name blue-green-devsecops-pipeline \
  --region ap-south-1

# Start pipeline manually
aws codepipeline start-pipeline-execution \
  --name blue-green-devsecops-pipeline \
  --region ap-south-1

# Stop pipeline execution
aws codepipeline stop-pipeline-execution \
  --pipeline-name blue-green-devsecops-pipeline \
  --pipeline-execution-id <execution-id> \
  --region ap-south-1
```

## 🏗️ CodeBuild Management

```bash
# List builds
aws codebuild list-builds-for-project \
  --project-name blue-green-devsecops-build \
  --region ap-south-1

# Get build details
aws codebuild batch-get-builds \
  --ids <build-id> \
  --region ap-south-1

# Start build manually
aws codebuild start-build \
  --project-name blue-green-devsecops-build \
  --region ap-south-1

# View build logs (live)
aws logs tail /aws/codebuild/blue-green-devsecops \
  --follow \
  --region ap-south-1

# View build logs (specific time)
aws logs tail /aws/codebuild/blue-green-devsecops \
  --since 1h \
  --region ap-south-1
```

## 🚢 CodeDeploy Management

```bash
# List deployments
aws deploy list-deployments \
  --application-name blue-green-devsecops-app \
  --region ap-south-1

# Get deployment details
aws deploy get-deployment \
  --deployment-id <deployment-id> \
  --region ap-south-1

# Create deployment
aws deploy create-deployment \
  --application-name blue-green-devsecops-app \
  --deployment-group-name blue-green-devsecops-deployment-group \
  --s3-location bucket=blue-green-codebuild-artifacts-792840215332,key=artifact.zip,bundleType=zip \
  --region ap-south-1

# Stop deployment
aws deploy stop-deployment \
  --deployment-id <deployment-id> \
  --auto-rollback-enabled \
  --region ap-south-1
```

## 🎯 Load Balancer Management

```bash
# Describe load balancers
aws elbv2 describe-load-balancers \
  --region ap-south-1

# Describe target groups
aws elbv2 describe-target-groups \
  --region ap-south-1

# Check target health (Blue)
aws elbv2 describe-target-health \
  --target-group-arn $BLUE_TG \
  --region ap-south-1

# Check target health (Green)
aws elbv2 describe-target-health \
  --target-group-arn $GREEN_TG \
  --region ap-south-1

# Get listener ARN
LISTENER_ARN=$(aws elbv2 describe-listeners \
  --load-balancer-arn $(aws elbv2 describe-load-balancers \
    --names blue-green-devsecops-alb \
    --region ap-south-1 \
    --query 'LoadBalancers[0].LoadBalancerArn' \
    --output text) \
  --region ap-south-1 \
  --query 'Listeners[0].ListenerArn' \
  --output text)

# Switch traffic to Blue
aws elbv2 modify-listener \
  --listener-arn $LISTENER_ARN \
  --default-actions Type=forward,TargetGroupArn=$BLUE_TG \
  --region ap-south-1

# Switch traffic to Green
aws elbv2 modify-listener \
  --listener-arn $LISTENER_ARN \
  --default-actions Type=forward,TargetGroupArn=$GREEN_TG \
  --region ap-south-1
```

## 💻 EC2 Instance Management

```bash
# List all project instances
aws ec2 describe-instances \
  --filters "Name=tag:Project,Values=blue-green-devsecops" \
  --region ap-south-1 \
  --query 'Reservations[*].Instances[*].[InstanceId,State.Name,PublicIpAddress,PrivateIpAddress,Tags[?Key==`Name`].Value|[0]]' \
  --output table

# List Blue instances
aws ec2 describe-instances \
  --filters "Name=tag:Environment,Values=blue" \
  --region ap-south-1 \
  --query 'Reservations[*].Instances[*].[InstanceId,PublicIpAddress]' \
  --output table

# List Green instances
aws ec2 describe-instances \
  --filters "Name=tag:Environment,Values=green" \
  --region ap-south-1 \
  --query 'Reservations[*].Instances[*].[InstanceId,PublicIpAddress]' \
  --output table

# Get SonarQube instance IP
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=blue-green-devsecops-sonarqube" \
  --region ap-south-1 \
  --query 'Reservations[0].Instances[0].PublicIpAddress' \
  --output text

# SSH into instance
ssh -i blue-green-key.pem ec2-user@<instance-ip>

# Start instance
aws ec2 start-instances \
  --instance-ids <instance-id> \
  --region ap-south-1

# Stop instance
aws ec2 stop-instances \
  --instance-ids <instance-id> \
  --region ap-south-1

# Reboot instance
aws ec2 reboot-instances \
  --instance-ids <instance-id> \
  --region ap-south-1
```

## 📦 S3 Bucket Management

```bash
# List buckets
aws s3 ls | grep blue-green

# List artifacts
aws s3 ls s3://blue-green-codebuild-artifacts-792840215332/ --recursive

# List security reports
aws s3 ls s3://blue-green-codebuild-792840215332/ --recursive

# Download Trivy reports
aws s3 cp s3://blue-green-codebuild-792840215332/trivyfilescan.txt ./
aws s3 cp s3://blue-green-codebuild-792840215332/trivyimage.txt ./

# Download OWASP report
aws s3 cp s3://blue-green-codebuild-792840215332/dependency-check-report/ ./ --recursive

# Upload file
aws s3 cp local-file.txt s3://blue-green-codebuild-792840215332/

# Delete file
aws s3 rm s3://blue-green-codebuild-792840215332/file.txt

# Empty bucket (for cleanup)
aws s3 rm s3://blue-green-codebuild-792840215332/ --recursive
```

## 📧 SNS and SES Management

```bash
# List SNS topics
aws sns list-topics --region ap-south-1

# List SNS subscriptions
aws sns list-subscriptions --region ap-south-1

# Publish test message
aws sns publish \
  --topic-arn arn:aws:sns:ap-south-1:792840215332:blue-green-devsecops-pipeline-notifications \
  --message "Test notification" \
  --region ap-south-1

# List SES identities
aws ses list-identities --region ap-south-1

# Get email verification status
aws ses get-identity-verification-attributes \
  --identities your-email@example.com \
  --region ap-south-1

# Verify email
aws ses verify-email-identity \
  --email-address your-email@example.com \
  --region ap-south-1

# Send test email
aws ses send-email \
  --from your-email@example.com \
  --to your-email@example.com \
  --subject "Test Email" \
  --text "This is a test email" \
  --region ap-south-1
```

## 📊 CloudWatch Management

```bash
# List log groups
aws logs describe-log-groups --region ap-south-1

# Tail logs (live)
aws logs tail /aws/codebuild/blue-green-devsecops \
  --follow \
  --region ap-south-1

# Get logs from last hour
aws logs tail /aws/codebuild/blue-green-devsecops \
  --since 1h \
  --region ap-south-1

# List alarms
aws cloudwatch describe-alarms --region ap-south-1

# Get alarm details
aws cloudwatch describe-alarms \
  --alarm-names blue-green-devsecops-build-failures \
  --region ap-south-1

# Disable alarm
aws cloudwatch disable-alarm-actions \
  --alarm-names blue-green-devsecops-build-failures \
  --region ap-south-1

# Enable alarm
aws cloudwatch enable-alarm-actions \
  --alarm-names blue-green-devsecops-build-failures \
  --region ap-south-1
```

## 🔗 GitHub Connection Management

```bash
# List connections
aws codestar-connections list-connections --region ap-south-1

# Get connection details
aws codestar-connections get-connection \
  --connection-arn <connection-arn> \
  --region ap-south-1

# Note: Connection activation must be done via AWS Console
```

## 🧪 Testing and Debugging

```bash
# Test ALB connectivity
curl -I http://$ALB_URL

# Test ALB with verbose output
curl -v http://$ALB_URL

# Test specific target
curl -I http://<instance-ip>:3000

# Check DNS resolution
nslookup $ALB_URL

# Test from specific location
curl -H "Host: $ALB_URL" http://<alb-ip>

# SSH into instance and check
ssh -i blue-green-key.pem ec2-user@<instance-ip>

# Once inside instance:
sudo docker ps                          # Check Docker containers
sudo systemctl status codedeploy-agent  # Check CodeDeploy agent
sudo journalctl -u codedeploy-agent -f  # View CodeDeploy logs
pm2 list                                # Check PM2 processes
pm2 logs                                # View application logs
curl localhost:3000                     # Test app locally
```

## 🔄 Terraform Management

```bash
# Initialize
terraform init

# Validate configuration
terraform validate

# Format code
terraform fmt -recursive

# Plan changes
terraform plan

# Apply changes
terraform apply

# Apply without confirmation
terraform apply -auto-approve

# Destroy specific resource
terraform destroy -target=aws_instance.blue[0]

# Destroy all
terraform destroy

# Show current state
terraform show

# List resources
terraform state list

# Show specific resource
terraform state show aws_instance.blue[0]

# Refresh state
terraform refresh

# Import existing resource
terraform import aws_instance.example i-1234567890abcdef0

# Taint resource (force recreation)
terraform taint aws_instance.blue[0]

# Untaint resource
terraform untaint aws_instance.blue[0]
```

## 🧹 Cleanup Commands

```bash
# Empty S3 buckets before destroying
aws s3 rm s3://blue-green-codebuild-792840215332/ --recursive
aws s3 rm s3://blue-green-codebuild-artifacts-792840215332/ --recursive

# Destroy infrastructure
terraform destroy

# Delete key pair
aws ec2 delete-key-pair \
  --key-name blue-green-key \
  --region ap-south-1

# Delete parameters
aws ssm delete-parameter --name /cicd/docker-credentials/username --region ap-south-1
aws ssm delete-parameter --name /cicd/docker-credentials/password --region ap-south-1
aws ssm delete-parameter --name /cicd/docker-registry/url --region ap-south-1
aws ssm delete-parameter --name /cicd/sonar/sonar-token --region ap-south-1

# Delete local files
rm -f blue-green-key.pem
rm -f terraform.tfvars
rm -rf .terraform/
rm -f terraform.tfstate*
```

## 📱 Useful One-Liners

```bash
# Get all instance IPs
aws ec2 describe-instances \
  --filters "Name=tag:Project,Values=blue-green-devsecops" \
  --query 'Reservations[*].Instances[*].PublicIpAddress' \
  --output text --region ap-south-1

# Check if all targets are healthy
aws elbv2 describe-target-health --target-group-arn $BLUE_TG --region ap-south-1 \
  --query 'TargetHealthDescriptions[*].TargetHealth.State' --output text

# Get latest pipeline execution status
aws codepipeline list-pipeline-executions \
  --pipeline-name blue-green-devsecops-pipeline \
  --max-items 1 \
  --region ap-south-1 \
  --query 'pipelineExecutionSummaries[0].status' \
  --output text

# Count running instances
aws ec2 describe-instances \
  --filters "Name=tag:Project,Values=blue-green-devsecops" "Name=instance-state-name,Values=running" \
  --query 'Reservations[*].Instances[*].InstanceId' \
  --output text --region ap-south-1 | wc -w

# Get total S3 storage used
aws s3 ls s3://blue-green-codebuild-792840215332/ --recursive --summarize | grep "Total Size"

# Check last build status
aws codebuild list-builds-for-project \
  --project-name blue-green-devsecops-build \
  --region ap-south-1 \
  --max-items 1 \
  --query 'ids[0]' \
  --output text | xargs -I {} aws codebuild batch-get-builds \
  --ids {} --region ap-south-1 \
  --query 'builds[0].buildStatus' \
  --output text
```

## 🔍 Monitoring Dashboard (CLI)

```bash
# Create a simple monitoring script
cat > monitor.sh << 'EOF'
#!/bin/bash
while true; do
  clear
  echo "=== Blue-Green DevSecOps Monitoring ==="
  echo ""
  echo "Pipeline Status:"
  aws codepipeline get-pipeline-state \
    --name blue-green-devsecops-pipeline \
    --region ap-south-1 \
    --query 'stageStates[*].[stageName,latestExecution.status]' \
    --output table
  
  echo ""
  echo "Target Health:"
  echo "Blue:"
  aws elbv2 describe-target-health \
    --target-group-arn $BLUE_TG \
    --region ap-south-1 \
    --query 'TargetHealthDescriptions[*].[Target.Id,TargetHealth.State]' \
    --output table
  
  echo "Green:"
  aws elbv2 describe-target-health \
    --target-group-arn $GREEN_TG \
    --region ap-south-1 \
    --query 'TargetHealthDescriptions[*].[Target.Id,TargetHealth.State]' \
    --output table
  
  sleep 30
done
EOF

chmod +x monitor.sh
./monitor.sh
```

---

## 📚 Additional Resources

- [AWS CLI Documentation](https://docs.aws.amazon.com/cli/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS CodePipeline](https://docs.aws.amazon.com/codepipeline/)
- [AWS CodeDeploy](https://docs.aws.amazon.com/codedeploy/)

---

**Quick Tip**: Add these to your `.bashrc` or `.zshrc` for easy access:

```bash
alias tf='terraform'
alias tfa='terraform apply'
alias tfp='terraform plan'
alias tfo='terraform output'
alias awsl='aws --region ap-south-1'
```
