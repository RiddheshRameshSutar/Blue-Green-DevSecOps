# ⚡ Quick Start Guide

Get your Blue-Green DevSecOps infrastructure up and running in 30 minutes!

## 🎯 Prerequisites (5 minutes)

```bash
# 1. Verify AWS CLI
aws --version
aws sts get-caller-identity

# 2. Verify Terraform
terraform --version

# 3. Set your region
export AWS_DEFAULT_REGION=ap-south-1
```

**Required Information:**
- ✅ Docker Hub username and password
- ✅ Email address for notifications
- ✅ GitHub repository access

---

## 🚀 Deployment Steps

### Step 1: Prepare (2 minutes)

```bash
# Navigate to terraform directory
cd terraform

# Create EC2 key pair
chmod +x create-key-pair.sh
./create-key-pair.sh
```

**Output**: `blue-green-key.pem` file created

### Step 2: Configure (3 minutes)

```bash
# Copy example configuration
cp terraform.tfvars.example terraform.tfvars

# Edit with your values
nano terraform.tfvars
```

**Update these values:**
```hcl
docker_username     = "YOUR_DOCKERHUB_USERNAME"
docker_password     = "YOUR_DOCKERHUB_PASSWORD"
notification_email  = "YOUR_EMAIL@example.com"
```

### Step 3: Deploy Infrastructure (15 minutes)

```bash
# Initialize Terraform
terraform init

# Review what will be created
terraform plan

# Deploy (takes ~15 minutes)
terraform apply -auto-approve
```

**What's being created:**
- ✅ VPC with subnets and gateways
- ✅ 5 EC2 instances (2 Blue + 2 Green + 1 SonarQube)
- ✅ Application Load Balancer
- ✅ CI/CD Pipeline (CodePipeline, CodeBuild, CodeDeploy)
- ✅ S3 buckets, IAM roles, Security groups
- ✅ Monitoring and notifications

### Step 4: Configure Secrets (2 minutes)

```bash
# Setup Parameter Store
chmod +x setup-parameters.sh
./setup-parameters.sh
```

**Enter when prompted:**
- Docker Hub username
- Docker Hub password
- Docker registry URL (press Enter for default)
- SonarQube token (leave empty for now)

### Step 5: Setup SonarQube (5 minutes)

```bash
# Get SonarQube URL
terraform output sonarqube_url
```

**In your browser:**
1. Open the SonarQube URL
2. Login: `admin` / `admin` (change password)
3. Create project: Key = `swiggy`, Name = `Swiggy Clone`
4. Generate token: My Account → Security → Generate Token
5. Copy the token

**Add token to AWS:**
```bash
aws ssm put-parameter \
  --name /cicd/sonar/sonar-token \
  --value "YOUR_SONARQUBE_TOKEN" \
  --type SecureString \
  --region ap-south-1
```

### Step 6: Activate GitHub Connection (2 minutes)

**In AWS Console:**
1. Go to: CodePipeline → Settings → Connections
2. Find: `blue-green-devsecops-github-connection`
3. Click: "Update pending connection"
4. Authorize AWS to access your GitHub
5. Select repository: `RiddheshRameshSutar/Blue-Green-DevSecOps`
6. Click: "Connect"

### Step 7: Verify Email (1 minute)

1. Check your email inbox
2. Look for: "Amazon SES Email Verification Request"
3. Click the verification link

### Step 8: Test Deployment (5 minutes)

```bash
# Trigger pipeline with a commit
cd /path/to/your/app/repo
echo "# Test" >> README.md
git add README.md
git commit -m "Test pipeline"
git push origin main

# Monitor pipeline
aws codepipeline get-pipeline-state \
  --name blue-green-devsecops-pipeline \
  --region ap-south-1
```

### Step 9: Access Application (1 minute)

```bash
# Get application URL
terraform output alb_url

# Test it
curl -I $(terraform output -raw alb_dns_name)
```

**Open in browser:**
```bash
echo "http://$(terraform output -raw alb_dns_name)"
```

---

## ✅ Verification Checklist

After deployment, verify:

```bash
# 1. Check all instances are running
aws ec2 describe-instances \
  --filters "Name=tag:Project,Values=blue-green-devsecops" \
  --query 'Reservations[*].Instances[*].[Tags[?Key==`Name`].Value|[0],State.Name]' \
  --output table --region ap-south-1

# 2. Check target health
BLUE_TG=$(terraform output -raw blue_target_group_arn)
GREEN_TG=$(terraform output -raw green_target_group_arn)

aws elbv2 describe-target-health --target-group-arn $BLUE_TG --region ap-south-1
aws elbv2 describe-target-health --target-group-arn $GREEN_TG --region ap-south-1

# 3. Check pipeline status
aws codepipeline get-pipeline-state \
  --name blue-green-devsecops-pipeline \
  --region ap-south-1 \
  --query 'stageStates[*].[stageName,latestExecution.status]' \
  --output table

# 4. Test application
curl -I http://$(terraform output -raw alb_dns_name)
```

**Expected Results:**
- ✅ All instances: `running`
- ✅ All targets: `healthy`
- ✅ Pipeline: `Succeeded`
- ✅ Application: HTTP 200 OK

---

## 📊 Quick Access Commands

```bash
# Export important values
export ALB_URL=$(terraform output -raw alb_dns_name)
export SONARQUBE_IP=$(terraform output -raw sonarqube_public_ip)
export BLUE_TG=$(terraform output -raw blue_target_group_arn)
export GREEN_TG=$(terraform output -raw green_target_group_arn)

# Access URLs
echo "Application: http://$ALB_URL"
echo "SonarQube: http://$SONARQUBE_IP:9000"

# View logs
aws logs tail /aws/codebuild/blue-green-devsecops --follow --region ap-south-1

# SSH into instance
ssh -i blue-green-key.pem ec2-user@<instance-ip>
```

---

## 🎯 What You've Deployed

### Infrastructure
- **VPC**: 1 VPC with 4 subnets (2 public, 2 private)
- **EC2**: 5 instances (2 Blue + 2 Green + 1 SonarQube)
- **ALB**: 1 Application Load Balancer
- **S3**: 2 buckets (artifacts + reports)
- **Total Resources**: ~50 AWS resources

### CI/CD Pipeline
- **Source**: GitHub integration
- **Build**: CodeBuild with security scans
- **Deploy**: CodeDeploy with Blue-Green strategy
- **Monitoring**: CloudWatch + SNS + SES

### Security
- **Scans**: Trivy (file + image), OWASP, SonarQube
- **Secrets**: AWS Parameter Store
- **Encryption**: All data encrypted at rest

---

## 🔄 Common Operations

### Trigger Pipeline Manually
```bash
aws codepipeline start-pipeline-execution \
  --name blue-green-devsecops-pipeline \
  --region ap-south-1
```

### Switch Traffic to Blue
```bash
LISTENER_ARN=$(aws elbv2 describe-listeners \
  --load-balancer-arn $(aws elbv2 describe-load-balancers \
    --names blue-green-devsecops-alb --region ap-south-1 \
    --query 'LoadBalancers[0].LoadBalancerArn' --output text) \
  --region ap-south-1 --query 'Listeners[0].ListenerArn' --output text)

aws elbv2 modify-listener \
  --listener-arn $LISTENER_ARN \
  --default-actions Type=forward,TargetGroupArn=$BLUE_TG \
  --region ap-south-1
```

### Switch Traffic to Green
```bash
aws elbv2 modify-listener \
  --listener-arn $LISTENER_ARN \
  --default-actions Type=forward,TargetGroupArn=$GREEN_TG \
  --region ap-south-1
```

### View Security Reports
```bash
# List reports
aws s3 ls s3://blue-green-codebuild-792840215332/ --recursive

# Download reports
aws s3 cp s3://blue-green-codebuild-792840215332/trivyfilescan.txt ./
aws s3 cp s3://blue-green-codebuild-792840215332/trivyimage.txt ./
```

---

## 🐛 Troubleshooting

### Pipeline Fails at Source
```bash
# Check GitHub connection
aws codestar-connections list-connections --region ap-south-1

# If PENDING, activate in AWS Console
```

### Build Fails - Parameters Not Found
```bash
# Re-run parameter setup
./setup-parameters.sh

# Verify parameters exist
aws ssm describe-parameters --region ap-south-1
```

### Application Returns 503
```bash
# Check target health
aws elbv2 describe-target-health --target-group-arn $BLUE_TG --region ap-south-1

# Check instance status
aws ec2 describe-instances \
  --filters "Name=tag:Environment,Values=blue" \
  --region ap-south-1 \
  --query 'Reservations[*].Instances[*].[InstanceId,State.Name,PublicIpAddress]' \
  --output table

# SSH and check logs
ssh -i blue-green-key.pem ec2-user@<instance-ip>
sudo journalctl -u codedeploy-agent -f
```

### SonarQube Not Accessible
```bash
# Wait 2-3 minutes for SonarQube to start

# Check SonarQube instance
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=blue-green-devsecops-sonarqube" \
  --region ap-south-1

# SSH and check Docker
ssh -i blue-green-key.pem ec2-user@$SONARQUBE_IP
sudo docker ps
sudo docker logs sonarqube
```

---

## 🧹 Cleanup

When you're done testing:

```bash
# Empty S3 buckets first
aws s3 rm s3://blue-green-codebuild-792840215332/ --recursive
aws s3 rm s3://blue-green-codebuild-artifacts-792840215332/ --recursive

# Destroy infrastructure
terraform destroy -auto-approve

# Delete key pair
aws ec2 delete-key-pair --key-name blue-green-key --region ap-south-1
rm -f blue-green-key.pem

# Delete parameters
aws ssm delete-parameter --name /cicd/docker-credentials/username --region ap-south-1
aws ssm delete-parameter --name /cicd/docker-credentials/password --region ap-south-1
aws ssm delete-parameter --name /cicd/docker-registry/url --region ap-south-1
aws ssm delete-parameter --name /cicd/sonar/sonar-token --region ap-south-1
```

---

## 📚 Next Steps

1. **Read Full Documentation**
   - `DEPLOYMENT_GUIDE.md` - Detailed deployment guide
   - `ARCHITECTURE.md` - Architecture details
   - `COMMANDS_REFERENCE.md` - All commands

2. **Customize Your Setup**
   - Modify instance types
   - Add more instances
   - Enable HTTPS
   - Add Auto Scaling

3. **Enhance Security**
   - Enable AWS WAF
   - Add CloudTrail
   - Implement GuardDuty
   - Enable VPC Flow Logs

4. **Optimize Costs**
   - Use Spot Instances
   - Enable Auto Scaling
   - Review S3 lifecycle policies
   - Consider Reserved Instances

---

## 💡 Pro Tips

1. **Save Outputs**: `terraform output > outputs.txt`
2. **Monitor Costs**: Enable AWS Cost Explorer
3. **Set Billing Alarms**: Avoid surprise charges
4. **Backup State**: Keep `terraform.tfstate` safe
5. **Use Tags**: All resources are tagged for easy tracking
6. **Check Logs**: CloudWatch logs are your friend
7. **Test Rollback**: Practice blue-green switching
8. **Document Changes**: Keep track of modifications

---

## 🎉 Success!

If you've completed all steps, you now have:

✅ Production-ready infrastructure  
✅ Automated CI/CD pipeline  
✅ Security scanning integrated  
✅ Zero-downtime deployments  
✅ Monitoring and alerts  
✅ High availability setup  

**Congratulations! You're now a DevOps engineer! 🚀**

---

## 📞 Need Help?

- Check `DEPLOYMENT_GUIDE.md` for detailed steps
- Review `COMMANDS_REFERENCE.md` for all commands
- See `ARCHITECTURE.md` for architecture details
- Check AWS CloudWatch logs for errors

---

**Total Time**: ~30 minutes  
**Difficulty**: Intermediate  
**Cost**: ~$270/month  
**Region**: ap-south-1  

**Happy Deploying! 🎯**
