# 🚀 Blue-Green DevSecOps Deployment Guide

Complete step-by-step guide for deploying the Swiggy Clone application with Blue-Green deployment strategy.

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Quick Start](#quick-start)
3. [Detailed Setup](#detailed-setup)
4. [Pipeline Configuration](#pipeline-configuration)
5. [Testing and Verification](#testing-and-verification)
6. [Operations](#operations)
7. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required Tools

Install the following tools before starting:

```bash
# AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Terraform
wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
unzip terraform_1.6.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/

# Verify installations
aws --version
terraform --version
```

### AWS Configuration

```bash
# Configure AWS CLI
aws configure

# Enter your credentials:
# AWS Access Key ID: YOUR_ACCESS_KEY
# AWS Secret Access Key: YOUR_SECRET_KEY
# Default region: ap-south-1
# Default output format: json

# Verify configuration
aws sts get-caller-identity
```

### Required Information

Gather the following before starting:

- ✅ AWS Account ID: `792840215332`
- ✅ AWS Region: `ap-south-1`
- ✅ Docker Hub username and password
- ✅ GitHub repository: `RiddheshRameshSutar/Blue-Green-DevSecOps`
- ✅ Email address for notifications

---

## Quick Start

For experienced users, here's the quick deployment:

```bash
# 1. Navigate to terraform directory
cd terraform

# 2. Create key pair
chmod +x create-key-pair.sh && ./create-key-pair.sh

# 3. Configure variables
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values

# 4. Deploy infrastructure
terraform init
terraform plan
terraform apply -auto-approve

# 5. Setup parameters
chmod +x setup-parameters.sh && ./setup-parameters.sh

# 6. Configure SonarQube (get URL from output)
terraform output sonarqube_url

# 7. Activate GitHub connection in AWS Console

# 8. Verify email for SES notifications

# Done! Push to GitHub to trigger pipeline
```

---

## Detailed Setup

### Step 1: Prepare Your Environment

```bash
# Clone the repository (if not already done)
git clone https://github.com/RiddheshRameshSutar/Blue-Green-DevSecOps.git
cd Blue-Green-DevSecOps

# Navigate to terraform directory
cd terraform

# Verify all files are present
ls -la
```

### Step 2: Create EC2 Key Pair

This key pair is required for SSH access to EC2 instances.

```bash
# Make the script executable
chmod +x create-key-pair.sh

# Run the script
./create-key-pair.sh

# Expected output:
# ==========================================
# Creating EC2 Key Pair
# ==========================================
# Creating new key pair: blue-green-key
# 
# ==========================================
# Key pair created successfully!
# ==========================================
# Key Name: blue-green-key
# Private Key File: blue-green-key.pem
```

**Important**: 
- Keep `blue-green-key.pem` file safe
- Don't commit it to Git
- You'll need it to SSH into instances

### Step 3: Configure Terraform Variables

```bash
# Copy example file
cp terraform.tfvars.example terraform.tfvars

# Edit the file
nano terraform.tfvars  # or use your preferred editor
```

Update these critical values:

```hcl
# Docker Hub credentials (REQUIRED)
docker_username = "your-dockerhub-username"
docker_password = "your-dockerhub-password"

# Your email for notifications (REQUIRED)
notification_email = "your-email@example.com"

# Verify these match your setup
aws_region     = "ap-south-1"
aws_account_id = "792840215332"
github_repo    = "RiddheshRameshSutar/Blue-Green-DevSecOps"
github_branch  = "main"
```

### Step 4: Initialize Terraform

```bash
# Initialize Terraform (downloads providers)
terraform init

# Expected output:
# Initializing the backend...
# Initializing provider plugins...
# - Finding hashicorp/aws versions matching "~> 5.0"...
# - Installing hashicorp/aws v5.x.x...
# Terraform has been successfully initialized!
```

### Step 5: Review Infrastructure Plan

```bash
# Generate and review execution plan
terraform plan

# This shows:
# - Resources to be created
# - Estimated costs
# - Any configuration errors
```

Review the plan carefully. You should see approximately 50+ resources to be created.

### Step 6: Deploy Infrastructure

```bash
# Apply the configuration
terraform apply

# Review the plan one more time
# Type 'yes' when prompted

# Deployment takes 10-15 minutes
# You'll see progress as resources are created
```

**What gets created:**

1. **Networking** (2-3 minutes)
   - VPC
   - 2 Public subnets
   - 2 Private subnets
   - Internet Gateway
   - 2 NAT Gateways
   - Route tables

2. **Security** (1 minute)
   - 4 Security groups
   - IAM roles and policies
   - Instance profiles

3. **Compute** (5-7 minutes)
   - 4 EC2 instances (2 Blue + 2 Green)
   - 1 SonarQube server
   - Application Load Balancer
   - Target groups

4. **CI/CD** (2-3 minutes)
   - CodePipeline
   - CodeBuild project
   - CodeDeploy application
   - S3 buckets
   - SNS topics
   - CloudWatch alarms

### Step 7: Save Terraform Outputs

```bash
# Save all outputs to a file
terraform output > outputs.txt

# View specific outputs
terraform output alb_url
terraform output sonarqube_url
terraform output codepipeline_name

# Export important values
export ALB_URL=$(terraform output -raw alb_dns_name)
export SONARQUBE_IP=$(terraform output -raw sonarqube_public_ip)
export SONARQUBE_URL=$(terraform output -raw sonarqube_url)

echo "Application URL: http://$ALB_URL"
echo "SonarQube URL: $SONARQUBE_URL"
```

---

## Pipeline Configuration

### Step 8: Configure AWS Systems Manager Parameter Store

The pipeline needs credentials stored securely in Parameter Store.

```bash
# Make script executable
chmod +x setup-parameters.sh

# Run the script
./setup-parameters.sh

# You'll be prompted for:
# 1. Docker Hub Username
# 2. Docker Hub Password
# 3. Docker Registry URL (default: docker.io)
# 4. SonarQube Token (optional at this stage)
```

**Example interaction:**

```
==========================================
Setting up AWS Systems Manager Parameters
==========================================

Enter your Docker Hub credentials:
Docker Hub Username: myusername
Docker Hub Password: ********

Docker Registry URL (default: docker.io): 

SonarQube Token (leave empty if not yet generated):

Creating parameters in AWS Systems Manager...
Creating parameter: /cicd/docker-credentials/username
Creating parameter: /cicd/docker-credentials/password
Creating parameter: /cicd/docker-registry/url

==========================================
Parameters created successfully!
==========================================
```

### Step 9: Configure SonarQube

SonarQube needs initial setup and token generation.

#### 9.1 Access SonarQube

```bash
# Get SonarQube URL
echo $SONARQUBE_URL

# Or
terraform output sonarqube_url
```

Open the URL in your browser: `http://<sonarqube-ip>:9000`

**Note**: SonarQube takes 2-3 minutes to start. If you get a connection error, wait and retry.

#### 9.2 Initial Login

- **Username**: `admin`
- **Password**: `admin`
- You'll be prompted to change the password

#### 9.3 Create Project

1. Click "Create Project" → "Manually"
2. Enter:
   - **Project key**: `swiggy`
   - **Display name**: `Swiggy Clone`
3. Click "Set Up"

#### 9.4 Generate Token

1. Go to: **My Account** (top right) → **Security**
2. Under "Generate Tokens":
   - **Name**: `cicd-pipeline`
   - **Type**: `Global Analysis Token`
   - **Expires**: `No expiration`
3. Click "Generate"
4. **Copy the token** (you won't see it again!)

#### 9.5 Add Token to Parameter Store

```bash
# Replace YOUR_TOKEN with the actual token
aws ssm put-parameter \
  --name /cicd/sonar/sonar-token \
  --value "YOUR_SONARQUBE_TOKEN" \
  --type SecureString \
  --region ap-south-1 \
  --overwrite

# Verify it was created
aws ssm get-parameter \
  --name /cicd/sonar/sonar-token \
  --with-decryption \
  --region ap-south-1
```

#### 9.6 Update buildspec.yaml

The buildspec.yaml in your repository has a hardcoded SonarQube URL. Update it:

```bash
# In your application repository, edit buildspec.yaml
# Find this line:
-Dsonar.host.url="http://13.204.62.114:9000/"

# Replace with your SonarQube IP:
-Dsonar.host.url="http://<YOUR_SONARQUBE_IP>:9000/"

# Commit and push
git add buildspec.yaml
git commit -m "Update SonarQube URL"
git push
```

### Step 10: Activate GitHub Connection

The CodePipeline needs permission to access your GitHub repository.

#### 10.1 Find the Connection

```bash
# Get connection ARN
aws codestar-connections list-connections --region ap-south-1

# Or check in AWS Console:
# CodePipeline → Settings → Connections
```

#### 10.2 Activate Connection

1. Go to AWS Console: https://console.aws.amazon.com/codesuite/settings/connections
2. Find connection: `blue-green-devsecops-github-connection`
3. Status will be "Pending"
4. Click "Update pending connection"
5. Click "Install a new app" or "Connect to GitHub"
6. Authorize AWS CodeStar
7. Select your repository: `RiddheshRameshSutar/Blue-Green-DevSecOps`
8. Click "Connect"
9. Status should change to "Available"

**Alternative: Using AWS CLI**

```bash
# This requires manual browser interaction, so use Console method above
```

### Step 11: Verify SES Email

AWS SES needs to verify your email address for notifications.

#### 11.1 Check Email

1. Check the inbox of the email you specified in `notification_email`
2. Look for email from: `no-reply-aws@amazon.com`
3. Subject: "Amazon SES Email Verification Request"

#### 11.2 Verify Email

1. Click the verification link in the email
2. You should see: "Congratulations! You've successfully verified..."

#### 11.3 Verify Status

```bash
# Check verification status
aws ses get-identity-verification-attributes \
  --identities your-email@example.com \
  --region ap-south-1

# Should show: "VerificationStatus": "Success"
```

---

## Testing and Verification

### Step 12: Test the Pipeline

Now everything is configured. Let's test the pipeline!

#### 12.1 Trigger Pipeline

```bash
# Make a small change to trigger the pipeline
cd /path/to/your/app/repo

# Make a change (e.g., update README)
echo "# Testing pipeline" >> README.md

# Commit and push
git add README.md
git commit -m "Test pipeline trigger"
git push origin main
```

#### 12.2 Monitor Pipeline

```bash
# Watch pipeline status
aws codepipeline get-pipeline-state \
  --name blue-green-devsecops-pipeline \
  --region ap-south-1

# Or use AWS Console:
# https://console.aws.amazon.com/codesuite/codepipeline/pipelines
```

#### 12.3 Check Pipeline Stages

The pipeline has 3 stages:

1. **Source** (1-2 minutes)
   - Pulls code from GitHub
   - Status: Should complete quickly

2. **Build** (5-10 minutes)
   - Runs security scans
   - Builds Docker image
   - Pushes to Docker Hub
   - Runs SonarQube analysis
   - Check logs:
     ```bash
     aws logs tail /aws/codebuild/blue-green-devsecops --follow --region ap-south-1
     ```

3. **Deploy** (5-10 minutes)
   - Deploys to Green environment
   - Runs health checks
   - Switches traffic
   - Check deployment:
     ```bash
     aws deploy get-deployment \
       --deployment-id <deployment-id> \
       --region ap-south-1
     ```

### Step 13: Verify Application

#### 13.1 Access Application

```bash
# Get ALB URL
echo "http://$ALB_URL"

# Or
terraform output alb_url
```

Open the URL in your browser. You should see the Swiggy Clone application.

#### 13.2 Check Target Health

```bash
# Get target group ARNs
BLUE_TG=$(terraform output -raw blue_target_group_arn)
GREEN_TG=$(terraform output -raw green_target_group_arn)

# Check Blue targets
aws elbv2 describe-target-health \
  --target-group-arn $BLUE_TG \
  --region ap-south-1

# Check Green targets
aws elbv2 describe-target-health \
  --target-group-arn $GREEN_TG \
  --region ap-south-1

# All targets should show "healthy"
```

#### 13.3 Check Security Reports

```bash
# List reports in S3
aws s3 ls s3://blue-green-codebuild-792840215332/ --recursive

# Download Trivy file scan report
aws s3 cp s3://blue-green-codebuild-792840215332/trivyfilescan.txt ./

# Download Trivy image scan report
aws s3 cp s3://blue-green-codebuild-792840215332/trivyimage.txt ./

# Download OWASP Dependency Check report
aws s3 cp s3://blue-green-codebuild-792840215332/dependency-check-report/ ./ --recursive

# View reports
cat trivyfilescan.txt
cat trivyimage.txt
```

#### 13.4 Check SonarQube Analysis

1. Go to SonarQube URL: `http://<sonarqube-ip>:9000`
2. Click on "Swiggy Clone" project
3. View:
   - Code quality metrics
   - Security vulnerabilities
   - Code smells
   - Coverage (if tests are configured)

---

## Operations

### Monitoring

#### View Logs

```bash
# CodeBuild logs
aws logs tail /aws/codebuild/blue-green-devsecops --follow --region ap-south-1

# EC2 instance logs (SSH required)
ssh -i blue-green-key.pem ec2-user@<instance-ip>
sudo tail -f /var/log/cloud-init-output.log
sudo journalctl -u codedeploy-agent -f
```

#### Check Pipeline Status

```bash
# Get pipeline execution history
aws codepipeline list-pipeline-executions \
  --pipeline-name blue-green-devsecops-pipeline \
  --region ap-south-1

# Get specific execution details
aws codepipeline get-pipeline-execution \
  --pipeline-name blue-green-devsecops-pipeline \
  --pipeline-execution-id <execution-id> \
  --region ap-south-1
```

### Manual Deployment

#### Deploy to Specific Environment

```bash
# Create deployment to Blue
aws deploy create-deployment \
  --application-name blue-green-devsecops-app \
  --deployment-group-name blue-green-devsecops-deployment-group \
  --s3-location bucket=blue-green-codebuild-artifacts-792840215332,key=path/to/artifact.zip,bundleType=zip \
  --region ap-south-1
```

### Traffic Management

#### Switch Traffic Between Blue and Green

```bash
# Get listener ARN
LISTENER_ARN=$(aws elbv2 describe-listeners \
  --load-balancer-arn $(terraform output -raw aws_lb.main.arn) \
  --region ap-south-1 \
  --query 'Listeners[0].ListenerArn' \
  --output text)

# Switch to Blue
aws elbv2 modify-listener \
  --listener-arn $LISTENER_ARN \
  --default-actions Type=forward,TargetGroupArn=$BLUE_TG \
  --region ap-south-1

# Switch to Green
aws elbv2 modify-listener \
  --listener-arn $LISTENER_ARN \
  --default-actions Type=forward,TargetGroupArn=$GREEN_TG \
  --region ap-south-1
```

### Rollback

#### Rollback Deployment

```bash
# Stop current deployment
aws deploy stop-deployment \
  --deployment-id <deployment-id> \
  --auto-rollback-enabled \
  --region ap-south-1

# Or manually switch traffic back to Blue
aws elbv2 modify-listener \
  --listener-arn $LISTENER_ARN \
  --default-actions Type=forward,TargetGroupArn=$BLUE_TG \
  --region ap-south-1
```

---

## Troubleshooting

### Common Issues and Solutions

#### Issue 1: Pipeline Fails at Source Stage

**Symptom**: Source stage shows "Failed"

**Cause**: GitHub connection not activated

**Solution**:
```bash
# Check connection status
aws codestar-connections list-connections --region ap-south-1

# If status is "PENDING", activate it in AWS Console
# CodePipeline → Settings → Connections → Update pending connection
```

#### Issue 2: Build Fails - Parameter Not Found

**Symptom**: Build fails with error about missing parameters

**Cause**: Parameter Store not configured

**Solution**:
```bash
# Run setup script
./setup-parameters.sh

# Or manually create parameters
aws ssm put-parameter \
  --name /cicd/docker-credentials/username \
  --value "your-username" \
  --type String \
  --region ap-south-1
```

#### Issue 3: SonarQube Not Accessible

**Symptom**: Cannot access SonarQube URL

**Cause**: SonarQube still starting or security group issue

**Solution**:
```bash
# Wait 2-3 minutes for SonarQube to start

# Check instance status
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=blue-green-devsecops-sonarqube" \
  --region ap-south-1

# SSH into instance and check
ssh -i blue-green-key.pem ec2-user@<sonarqube-ip>
sudo docker ps
sudo docker logs sonarqube
```

#### Issue 4: Application Not Accessible via ALB

**Symptom**: ALB URL returns 503 or timeout

**Cause**: Targets unhealthy or application not running

**Solution**:
```bash
# Check target health
aws elbv2 describe-target-health \
  --target-group-arn $BLUE_TG \
  --region ap-south-1

# SSH into instance
ssh -i blue-green-key.pem ec2-user@<instance-ip>

# Check if application is running
sudo docker ps
sudo pm2 list

# Check application logs
sudo journalctl -u codedeploy-agent -f
```

#### Issue 5: Email Notifications Not Working

**Symptom**: Not receiving pipeline notifications

**Cause**: Email not verified in SES

**Solution**:
```bash
# Check verification status
aws ses get-identity-verification-attributes \
  --identities your-email@example.com \
  --region ap-south-1

# If not verified, check email for verification link
# Or resend verification
aws ses verify-email-identity \
  --email-address your-email@example.com \
  --region ap-south-1
```

### Debug Commands

```bash
# Check all EC2 instances
aws ec2 describe-instances \
  --filters "Name=tag:Project,Values=blue-green-devsecops" \
  --region ap-south-1 \
  --query 'Reservations[*].Instances[*].[InstanceId,State.Name,PublicIpAddress,Tags[?Key==`Name`].Value|[0]]' \
  --output table

# Check CodeDeploy deployments
aws deploy list-deployments \
  --application-name blue-green-devsecops-app \
  --region ap-south-1

# Check S3 buckets
aws s3 ls | grep blue-green

# Check Parameter Store
aws ssm describe-parameters \
  --region ap-south-1 \
  --query 'Parameters[?contains(Name, `/cicd/`)]'

# Test ALB connectivity
curl -I http://$ALB_URL
```

---

## Summary

You've successfully deployed a complete Blue-Green DevSecOps infrastructure! 🎉

### What You've Accomplished:

✅ Created VPC with public/private subnets  
✅ Deployed Application Load Balancer  
✅ Launched Blue and Green EC2 environments  
✅ Set up SonarQube for code quality  
✅ Configured CI/CD pipeline with security scanning  
✅ Enabled automated blue-green deployments  
✅ Set up monitoring and notifications  

### Next Steps:

1. **Customize Application**: Modify the Swiggy Clone app
2. **Add Tests**: Implement unit and integration tests
3. **Configure Monitoring**: Set up CloudWatch dashboards
4. **Optimize Costs**: Review and adjust instance types
5. **Enhance Security**: Add WAF, enable HTTPS
6. **Scale**: Add auto-scaling groups

### Useful Links:

- Application: `http://$ALB_URL`
- SonarQube: `http://<sonarqube-ip>:9000`
- AWS Console: https://console.aws.amazon.com/
- CodePipeline: https://console.aws.amazon.com/codesuite/codepipeline/pipelines

---

**Happy Deploying! 🚀**
