# Blue-Green DevSecOps Infrastructure

Complete Terraform infrastructure for deploying a React application (Swiggy Clone) with Blue-Green deployment strategy and integrated DevSecOps pipeline.

## 📋 Architecture Overview

This infrastructure includes:

- **VPC**: Custom VPC with public and private subnets across 2 availability zones
- **Compute**: EC2 instances for Blue/Green environments + SonarQube server
- **Load Balancing**: Application Load Balancer with Blue/Green target groups
- **CI/CD Pipeline**: CodePipeline → CodeBuild → CodeDeploy
- **Security Scanning**: Trivy, OWASP Dependency Check, SonarQube
- **Storage**: S3 buckets for artifacts and security reports
- **Monitoring**: CloudWatch logs, SNS/SES notifications

## 🚀 Prerequisites

Before you begin, ensure you have:

1. **AWS CLI** installed and configured
   ```bash
   aws --version
   aws configure
   ```

2. **Terraform** installed (version >= 1.0)
   ```bash
   terraform --version
   ```

3. **AWS Account** with appropriate permissions
   - Account ID: `792840215332`
   - Region: `ap-south-1`

4. **Docker Hub Account** for container registry

5. **GitHub Repository** with your application code

## 📦 Project Structure

```
terraform/
├── main.tf                    # Provider and backend configuration
├── variables.tf               # Input variables
├── outputs.tf                 # Output values
├── terraform.tfvars.example   # Example variable values
├── vpc.tf                     # VPC and networking
├── security-groups.tf         # Security groups
├── alb.tf                     # Application Load Balancer
├── ec2.tf                     # EC2 instances (Blue/Green)
├── sonarqube.tf              # SonarQube server
├── iam.tf                     # IAM roles and policies
├── s3.tf                      # S3 buckets
├── codepipeline.tf           # CI/CD pipeline
├── sns-ses.tf                # Notifications
├── setup-parameters.sh        # Script to setup Parameter Store
├── create-key-pair.sh        # Script to create EC2 key pair
└── README.md                  # This file
```

## 🔧 Setup Instructions

### Step 1: Clone and Prepare

```bash
# Navigate to terraform directory
cd terraform

# Copy example tfvars file
cp terraform.tfvars.example terraform.tfvars
```

### Step 2: Configure Variables

Edit `terraform.tfvars` and update the following:

```hcl
# Docker Hub credentials
docker_username = "your-dockerhub-username"
docker_password = "your-dockerhub-password"

# Your email for notifications
notification_email = "your-email@example.com"

# Verify other settings match your requirements
```

### Step 3: Create EC2 Key Pair

```bash
# Make script executable
chmod +x create-key-pair.sh

# Run the script
./create-key-pair.sh
```

This creates a key pair named `blue-green-key` and saves the private key as `blue-green-key.pem`.

**⚠️ IMPORTANT**: Keep the `.pem` file safe! You'll need it to SSH into EC2 instances.

### Step 4: Initialize Terraform

```bash
# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Preview changes
terraform plan
```

### Step 5: Deploy Infrastructure

```bash
# Apply Terraform configuration
terraform apply

# Review the plan and type 'yes' to confirm
```

This will create:
- VPC with subnets, IGW, NAT gateways
- Security groups
- Application Load Balancer
- 4 EC2 instances (2 Blue + 2 Green)
- SonarQube server
- S3 buckets
- IAM roles
- CodePipeline, CodeBuild, CodeDeploy
- SNS topics and CloudWatch alarms

**⏱️ Deployment Time**: Approximately 10-15 minutes

### Step 6: Configure AWS Systems Manager Parameter Store

After infrastructure is created, set up the parameters for the CI/CD pipeline:

```bash
# Make script executable
chmod +x setup-parameters.sh

# Run the script
./setup-parameters.sh
```

This script will prompt you for:
- Docker Hub username
- Docker Hub password
- Docker registry URL
- SonarQube token (optional at this stage)

### Step 7: Configure SonarQube

1. Get SonarQube URL from Terraform output:
   ```bash
   terraform output sonarqube_url
   ```

2. Access SonarQube in your browser:
   - URL: `http://<sonarqube-ip>:9000`
   - Default credentials: `admin` / `admin`
   - Change password on first login

3. Create a new project:
   - Project key: `swiggy`
   - Project name: `Swiggy Clone`

4. Generate authentication token:
   - Go to: My Account → Security → Generate Token
   - Copy the token

5. Add token to Parameter Store:
   ```bash
   aws ssm put-parameter \
     --name /cicd/sonar/sonar-token \
     --value "YOUR_SONARQUBE_TOKEN" \
     --type SecureString \
     --region ap-south-1
   ```

6. Update buildspec.yaml with SonarQube URL:
   - Replace the hardcoded IP with your SonarQube instance IP

### Step 8: Activate GitHub Connection

1. Go to AWS Console → CodePipeline → Settings → Connections
2. Find the connection named `blue-green-devsecops-github-connection`
3. Click "Update pending connection"
4. Authorize AWS to access your GitHub repository
5. Complete the connection setup

### Step 9: Verify Email for SES

1. Check your email for AWS SES verification email
2. Click the verification link
3. This enables email notifications from the pipeline

### Step 10: Test the Pipeline

1. Make a commit to your GitHub repository
2. CodePipeline will automatically trigger
3. Monitor the pipeline in AWS Console

## 📊 Accessing Resources

After deployment, get important URLs and information:

```bash
# Get all outputs
terraform output

# Specific outputs
terraform output alb_url              # Application URL
terraform output sonarqube_url        # SonarQube URL
terraform output codepipeline_name    # Pipeline name
```

### Application Access

```bash
# Get ALB URL
ALB_URL=$(terraform output -raw alb_dns_name)
echo "Application: http://$ALB_URL"
```

### SSH into EC2 Instances

```bash
# Get instance IPs
terraform output blue_instance_ids
terraform output green_instance_ids

# SSH into an instance
ssh -i blue-green-key.pem ec2-user@<instance-public-ip>
```

## 🔄 Blue-Green Deployment Process

The pipeline automatically performs blue-green deployments:

1. **Source Stage**: Pulls code from GitHub
2. **Build Stage**: 
   - Runs security scans (Trivy, OWASP)
   - Builds Docker image
   - Pushes to Docker Hub
   - Runs SonarQube analysis
3. **Deploy Stage**:
   - Deploys to Green environment
   - Runs health checks
   - Switches ALB traffic to Green
   - Keeps Blue environment for rollback

### Manual Traffic Switch

To manually switch traffic between Blue and Green:

```bash
# Switch to Blue
aws elbv2 modify-listener \
  --listener-arn $(terraform output -raw aws_lb_listener.http.arn) \
  --default-actions Type=forward,TargetGroupArn=$(terraform output -raw blue_target_group_arn) \
  --region ap-south-1

# Switch to Green
aws elbv2 modify-listener \
  --listener-arn $(terraform output -raw aws_lb_listener.http.arn) \
  --default-actions Type=forward,TargetGroupArn=$(terraform output -raw green_target_group_arn) \
  --region ap-south-1
```

## 🔒 Security Features

### Security Scanning

The pipeline includes multiple security scans:

1. **Trivy File Scan**: Scans source code for vulnerabilities
2. **Trivy Image Scan**: Scans Docker image for vulnerabilities
3. **OWASP Dependency Check**: Analyzes dependencies for known vulnerabilities
4. **SonarQube**: Code quality and security analysis

### Security Reports

All security reports are stored in S3:

```bash
# List security reports
aws s3 ls s3://blue-green-codebuild-792840215332/ --recursive

# Download a report
aws s3 cp s3://blue-green-codebuild-792840215332/trivyfilescan.txt ./
```

### Secrets Management

All sensitive data is stored in AWS Systems Manager Parameter Store:

```bash
# List parameters
aws ssm describe-parameters --region ap-south-1

# Get a parameter value (non-secure)
aws ssm get-parameter --name /cicd/docker-registry/url --region ap-south-1

# Get a secure parameter value
aws ssm get-parameter --name /cicd/docker-credentials/password --with-decryption --region ap-south-1
```

## 📈 Monitoring and Notifications

### CloudWatch Logs

View logs for different components:

```bash
# CodeBuild logs
aws logs tail /aws/codebuild/blue-green-devsecops --follow --region ap-south-1
```

### SNS Notifications

You'll receive email notifications for:
- Pipeline state changes (SUCCESS/FAILURE)
- CodeBuild state changes
- Build failures (CloudWatch Alarm)

### CloudWatch Alarms

Monitor alarms in AWS Console:
- Build failures alarm triggers when any build fails

## 🛠️ Maintenance Commands

### Update Infrastructure

```bash
# Make changes to .tf files
# Preview changes
terraform plan

# Apply changes
terraform apply
```

### View Current State

```bash
# Show current state
terraform show

# List all resources
terraform state list

# Show specific resource
terraform state show aws_instance.blue[0]
```

### Refresh Outputs

```bash
terraform refresh
terraform output
```

## 🧹 Cleanup

To destroy all resources:

```bash
# Preview what will be destroyed
terraform plan -destroy

# Destroy all resources
terraform destroy

# Type 'yes' to confirm
```

**⚠️ WARNING**: This will permanently delete:
- All EC2 instances
- Load balancers
- S3 buckets (if empty)
- VPC and networking components
- All other resources

### Manual Cleanup Steps

Some resources may need manual cleanup:

1. **S3 Buckets**: Empty buckets before destroying
   ```bash
   aws s3 rm s3://blue-green-codebuild-792840215332 --recursive
   aws s3 rm s3://blue-green-codebuild-artifacts-792840215332 --recursive
   ```

2. **GitHub Connection**: Delete from AWS Console if needed

3. **SES Email Identity**: Remains verified (no action needed)

## 🐛 Troubleshooting

### Common Issues

#### 1. Key Pair Not Found

**Error**: `InvalidKeyPair.NotFound`

**Solution**: Run `./create-key-pair.sh` before `terraform apply`

#### 2. GitHub Connection Pending

**Error**: Pipeline fails at Source stage

**Solution**: Activate GitHub connection in AWS Console (Step 8)

#### 3. SonarQube Not Accessible

**Issue**: Cannot access SonarQube URL

**Solution**: 
- Check security group allows port 9000
- Wait 2-3 minutes for SonarQube to start
- Check instance status: `aws ec2 describe-instances`

#### 4. Build Fails - Parameter Not Found

**Error**: Parameter `/cicd/docker-credentials/username` not found

**Solution**: Run `./setup-parameters.sh` to create parameters

#### 5. Email Notifications Not Working

**Issue**: Not receiving emails

**Solution**: 
- Verify email in SES (check inbox for verification email)
- Check SNS subscription status in AWS Console

### Debug Commands

```bash
# Check EC2 instance status
aws ec2 describe-instances --filters "Name=tag:Project,Values=blue-green-devsecops" --region ap-south-1

# Check CodePipeline status
aws codepipeline get-pipeline-state --name blue-green-devsecops-pipeline --region ap-south-1

# Check CodeBuild logs
aws logs tail /aws/codebuild/blue-green-devsecops --follow --region ap-south-1

# Check ALB target health
aws elbv2 describe-target-health --target-group-arn <target-group-arn> --region ap-south-1

# SSH into instance and check logs
ssh -i blue-green-key.pem ec2-user@<instance-ip>
sudo tail -f /var/log/cloud-init-output.log
sudo systemctl status codedeploy-agent
```

## 📚 Additional Resources

- [AWS CodePipeline Documentation](https://docs.aws.amazon.com/codepipeline/)
- [AWS CodeDeploy Blue/Green Deployments](https://docs.aws.amazon.com/codedeploy/latest/userguide/welcome.html)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [SonarQube Documentation](https://docs.sonarqube.org/)
- [Trivy Documentation](https://aquasecurity.github.io/trivy/)

## 🤝 Support

For issues or questions:
1. Check the Troubleshooting section above
2. Review AWS CloudWatch logs
3. Check Terraform state: `terraform show`

## 📝 Notes

- **Cost Optimization**: This setup uses t3.medium instances. Adjust instance types in `terraform.tfvars` based on your needs.
- **High Availability**: Resources are distributed across 2 availability zones.
- **Security**: All data at rest is encrypted, and secrets are stored in Parameter Store.
- **Scalability**: You can easily add more instances by modifying the configuration.

## ✅ Checklist

Before going to production:

- [ ] Create EC2 key pair
- [ ] Update terraform.tfvars with your values
- [ ] Run terraform apply
- [ ] Configure Parameter Store (run setup-parameters.sh)
- [ ] Set up SonarQube and generate token
- [ ] Activate GitHub connection
- [ ] Verify SES email
- [ ] Test pipeline with a commit
- [ ] Verify application is accessible via ALB
- [ ] Check security scan reports in S3
- [ ] Set up CloudWatch dashboards (optional)
- [ ] Configure backup strategy (optional)

---

**Project**: Blue-Green DevSecOps Infrastructure  
**Region**: ap-south-1 (Mumbai)  
**Managed By**: Terraform  
**Last Updated**: November 2025
