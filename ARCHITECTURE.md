# 🏗️ Blue-Green DevSecOps Architecture

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              AWS Cloud (ap-south-1)                          │
│                                                                              │
│  ┌────────────────────────────────────────────────────────────────────────┐ │
│  │                         VPC (10.0.0.0/16)                              │ │
│  │                                                                        │ │
│  │  ┌──────────────────────────────────────────────────────────────────┐ │ │
│  │  │                    Availability Zone 1a                          │ │ │
│  │  │                                                                  │ │ │
│  │  │  ┌─────────────────────┐      ┌─────────────────────┐          │ │ │
│  │  │  │  Public Subnet      │      │  Private Subnet     │          │ │ │
│  │  │  │  10.0.1.0/24        │      │  10.0.11.0/24       │          │ │ │
│  │  │  │                     │      │                     │          │ │ │
│  │  │  │  ┌──────────────┐   │      │                     │          │ │ │
│  │  │  │  │ Blue EC2 #1  │   │      │                     │          │ │ │
│  │  │  │  │ (App Server) │   │      │                     │          │ │ │
│  │  │  │  └──────────────┘   │      │                     │          │ │ │
│  │  │  │                     │      │                     │          │ │ │
│  │  │  │  ┌──────────────┐   │      │                     │          │ │ │
│  │  │  │  │ Green EC2 #1 │   │      │                     │          │ │ │
│  │  │  │  │ (App Server) │   │      │                     │          │ │ │
│  │  │  │  └──────────────┘   │      │                     │          │ │ │
│  │  │  │                     │      │                     │          │ │ │
│  │  │  │  ┌──────────────┐   │      │                     │          │ │ │
│  │  │  │  │  SonarQube   │   │      │                     │          │ │ │
│  │  │  │  │   Server     │   │      │                     │          │ │ │
│  │  │  │  └──────────────┘   │      │                     │          │ │ │
│  │  │  │         │            │      │                     │          │ │ │
│  │  │  │         │            │      │                     │          │ │ │
│  │  │  │  ┌──────▼───────┐   │      │  ┌──────────────┐   │          │ │ │
│  │  │  │  │  NAT Gateway │───┼──────┼─▶│  CodeBuild   │   │          │ │ │
│  │  │  │  └──────────────┘   │      │  │   (VPC)      │   │          │ │ │
│  │  │  └─────────────────────┘      │  └──────────────┘   │          │ │ │
│  │  │                                └─────────────────────┘          │ │ │
│  │  └──────────────────────────────────────────────────────────────────┘ │ │
│  │                                                                        │ │
│  │  ┌──────────────────────────────────────────────────────────────────┐ │ │
│  │  │                    Availability Zone 1b                          │ │ │
│  │  │                                                                  │ │ │
│  │  │  ┌─────────────────────┐      ┌─────────────────────┐          │ │ │
│  │  │  │  Public Subnet      │      │  Private Subnet     │          │ │ │
│  │  │  │  10.0.2.0/24        │      │  10.0.12.0/24       │          │ │ │
│  │  │  │                     │      │                     │          │ │ │
│  │  │  │  ┌──────────────┐   │      │                     │          │ │ │
│  │  │  │  │ Blue EC2 #2  │   │      │                     │          │ │ │
│  │  │  │  │ (App Server) │   │      │                     │          │ │ │
│  │  │  │  └──────────────┘   │      │                     │          │ │ │
│  │  │  │                     │      │                     │          │ │ │
│  │  │  │  ┌──────────────┐   │      │                     │          │ │ │
│  │  │  │  │ Green EC2 #2 │   │      │                     │          │ │ │
│  │  │  │  │ (App Server) │   │      │                     │          │ │ │
│  │  │  │  └──────────────┘   │      │                     │          │ │ │
│  │  │  │         │            │      │                     │          │ │ │
│  │  │  │  ┌──────▼───────┐   │      │                     │          │ │ │
│  │  │  │  │  NAT Gateway │   │      │                     │          │ │ │
│  │  │  │  └──────────────┘   │      │                     │          │ │ │
│  │  │  └─────────────────────┘      └─────────────────────┘          │ │ │
│  │  └──────────────────────────────────────────────────────────────────┘ │ │
│  │                                                                        │ │
│  │  ┌──────────────────────────────────────────────────────────────────┐ │ │
│  │  │                  Application Load Balancer                       │ │ │
│  │  │                                                                  │ │ │
│  │  │  ┌─────────────────┐              ┌─────────────────┐          │ │ │
│  │  │  │ Blue Target     │              │ Green Target    │          │ │ │
│  │  │  │ Group           │              │ Group           │          │ │ │
│  │  │  │ (Port 3000)     │              │ (Port 3000)     │          │ │ │
│  │  │  └─────────────────┘              └─────────────────┘          │ │ │
│  │  │           │                                 │                   │ │ │
│  │  │           └─────────────┬───────────────────┘                   │ │ │
│  │  │                         │                                       │ │ │
│  │  │                  ┌──────▼──────┐                                │ │ │
│  │  │                  │  Listener   │                                │ │ │
│  │  │                  │  (Port 80)  │                                │ │ │
│  │  │                  └──────┬──────┘                                │ │ │
│  │  └─────────────────────────┼──────────────────────────────────────┘ │ │
│  │                            │                                         │ │
│  │  ┌─────────────────────────▼──────────────────────────────────────┐ │ │
│  │  │                  Internet Gateway                               │ │ │
│  │  └─────────────────────────┬──────────────────────────────────────┘ │ │
│  └────────────────────────────┼────────────────────────────────────────┘ │
│                               │                                           │
└───────────────────────────────┼───────────────────────────────────────────┘
                                │
                    ┌───────────▼───────────┐
                    │   Internet Users      │
                    └───────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                          CI/CD Pipeline Flow                                 │
│                                                                              │
│  ┌──────────┐      ┌──────────┐      ┌──────────┐      ┌──────────┐       │
│  │          │      │          │      │          │      │          │       │
│  │  GitHub  │─────▶│CodePipe- │─────▶│CodeBuild │─────▶│CodeDeploy│       │
│  │  Repo    │      │  line    │      │          │      │          │       │
│  │          │      │          │      │          │      │          │       │
│  └──────────┘      └──────────┘      └────┬─────┘      └────┬─────┘       │
│                                            │                  │             │
│                                            │                  │             │
│                                     ┌──────▼──────┐    ┌──────▼──────┐     │
│                                     │   Docker    │    │   Deploy    │     │
│                                     │   Hub       │    │   to Green  │     │
│                                     └─────────────┘    └──────┬──────┘     │
│                                                               │             │
│                                     ┌─────────────────────────▼──────┐     │
│                                     │  Switch ALB Traffic to Green   │     │
│                                     └────────────────────────────────┘     │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                          Security Scanning Flow                              │
│                                                                              │
│  ┌──────────────┐                                                           │
│  │  CodeBuild   │                                                           │
│  │   Starts     │                                                           │
│  └──────┬───────┘                                                           │
│         │                                                                    │
│         ├──────────────┐                                                    │
│         │              │                                                    │
│  ┌──────▼──────┐  ┌────▼────────┐                                          │
│  │   Trivy     │  │    OWASP    │                                          │
│  │ File Scan   │  │ Dependency  │                                          │
│  │             │  │   Check     │                                          │
│  └──────┬──────┘  └────┬────────┘                                          │
│         │              │                                                    │
│         │              │                                                    │
│  ┌──────▼──────────────▼──────┐                                            │
│  │   Build Docker Image       │                                            │
│  └──────┬─────────────────────┘                                            │
│         │                                                                    │
│  ┌──────▼──────┐                                                           │
│  │   Trivy     │                                                           │
│  │ Image Scan  │                                                           │
│  └──────┬──────┘                                                           │
│         │                                                                    │
│  ┌──────▼──────────┐                                                       │
│  │   SonarQube     │                                                       │
│  │    Analysis     │                                                       │
│  └──────┬──────────┘                                                       │
│         │                                                                    │
│  ┌──────▼──────────┐                                                       │
│  │  Upload Reports │                                                       │
│  │    to S3        │                                                       │
│  └─────────────────┘                                                       │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                          Storage & Monitoring                                │
│                                                                              │
│  ┌─────────────────┐         ┌─────────────────┐                           │
│  │  S3 Bucket      │         │  S3 Bucket      │                           │
│  │  (Artifacts)    │         │  (Reports)      │                           │
│  │                 │         │                 │                           │
│  │  - Pipeline     │         │  - Trivy Scans  │                           │
│  │    Artifacts    │         │  - OWASP Report │                           │
│  │  - Build Output │         │  - Security     │                           │
│  └─────────────────┘         │    Reports      │                           │
│                              └─────────────────┘                           │
│                                                                              │
│  ┌─────────────────┐         ┌─────────────────┐                           │
│  │  CloudWatch     │         │  SNS Topic      │                           │
│  │  Logs           │         │                 │                           │
│  │                 │         │  - Email        │                           │
│  │  - CodeBuild    │         │    Notifications│                           │
│  │  - Application  │         │  - Pipeline     │                           │
│  │  - System       │         │    Alerts       │                           │
│  └─────────────────┘         └─────────────────┘                           │
│                                                                              │
│  ┌─────────────────────────────────────────────┐                           │
│  │  Parameter Store (Secrets)                  │                           │
│  │                                             │                           │
│  │  - Docker Hub Credentials                   │                           │
│  │  - SonarQube Token                          │                           │
│  │  - Docker Registry URL                      │                           │
│  └─────────────────────────────────────────────┘                           │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
```

## Component Details

### 1. Network Layer

#### VPC Configuration
- **CIDR Block**: 10.0.0.0/16
- **DNS Support**: Enabled
- **DNS Hostnames**: Enabled

#### Subnets
| Type    | AZ          | CIDR         | Purpose                    |
|---------|-------------|--------------|----------------------------|
| Public  | ap-south-1a | 10.0.1.0/24  | App servers, ALB, SonarQube|
| Public  | ap-south-1b | 10.0.2.0/24  | App servers, ALB           |
| Private | ap-south-1a | 10.0.11.0/24 | CodeBuild, future services |
| Private | ap-south-1b | 10.0.12.0/24 | CodeBuild, future services |

#### Gateways
- **Internet Gateway**: 1 (for public internet access)
- **NAT Gateways**: 2 (one per AZ for high availability)

### 2. Compute Layer

#### Application Servers (Blue Environment)
- **Count**: 2 instances
- **Type**: t3.medium
- **OS**: Amazon Linux 2023
- **Software**: Node.js 18, Docker, CodeDeploy Agent, PM2
- **Purpose**: Active production environment

#### Application Servers (Green Environment)
- **Count**: 2 instances
- **Type**: t3.medium
- **OS**: Amazon Linux 2023
- **Software**: Node.js 18, Docker, CodeDeploy Agent, PM2
- **Purpose**: Staging/new deployment environment

#### SonarQube Server
- **Count**: 1 instance
- **Type**: t3.medium
- **OS**: Amazon Linux 2023
- **Software**: Docker, SonarQube LTS Community
- **Purpose**: Code quality and security analysis

### 3. Load Balancing

#### Application Load Balancer
- **Type**: Application Load Balancer
- **Scheme**: Internet-facing
- **Subnets**: Both public subnets
- **Listeners**: HTTP (Port 80)
- **Health Check**: HTTP GET / (Port 3000)

#### Target Groups
| Name  | Port | Protocol | Health Check Path | Deregistration Delay |
|-------|------|----------|-------------------|----------------------|
| Blue  | 3000 | HTTP     | /                 | 30 seconds           |
| Green | 3000 | HTTP     | /                 | 30 seconds           |

### 4. CI/CD Pipeline

#### CodePipeline Stages

**Stage 1: Source**
- **Provider**: GitHub (via CodeStar Connection)
- **Repository**: RiddheshRameshSutar/Blue-Green-DevSecOps
- **Branch**: main
- **Trigger**: Automatic on push

**Stage 2: Build**
- **Provider**: CodeBuild
- **Environment**: Ubuntu Standard 7.0
- **Compute**: BUILD_GENERAL1_MEDIUM
- **Privileged Mode**: Enabled (for Docker)
- **Build Spec**: buildspec.yaml

**Stage 3: Deploy**
- **Provider**: CodeDeploy
- **Deployment Type**: Blue/Green
- **Traffic Shifting**: All at once
- **Rollback**: Automatic on failure

#### CodeBuild Process

1. **Pre-Build Phase**
   - Install Trivy scanner
   - Install OWASP Dependency Check
   - Install SonarQube scanner
   - Run Trivy file system scan

2. **Build Phase**
   - Login to Docker Hub
   - Build Docker image
   - Push image to Docker Hub

3. **Post-Build Phase**
   - Run Trivy image scan
   - Run OWASP Dependency Check
   - Upload reports to S3
   - Run SonarQube analysis
   - Send email notification

#### CodeDeploy Configuration

- **Deployment Type**: Blue/Green
- **Traffic Routing**: All at once
- **Original Instances**: Keep alive for 60 minutes
- **Deployment Ready**: Continue immediately
- **Green Fleet**: Discover existing instances
- **Rollback**: Automatic on failure or alarm

### 5. Security

#### Security Groups

**ALB Security Group**
- Inbound: HTTP (80), HTTPS (443) from 0.0.0.0/0
- Outbound: All traffic

**Application Security Group**
- Inbound: HTTP (80), App (3000) from ALB, SSH (22) from anywhere
- Outbound: All traffic

**SonarQube Security Group**
- Inbound: HTTP (9000), SSH (22) from anywhere
- Outbound: All traffic

**CodeBuild Security Group**
- Inbound: None
- Outbound: All traffic

#### IAM Roles

| Role         | Purpose                          | Key Permissions                    |
|--------------|----------------------------------|------------------------------------|
| EC2          | Application instances            | S3, SSM, CloudWatch                |
| CodePipeline | Orchestrate pipeline             | CodeBuild, CodeDeploy, S3          |
| CodeBuild    | Build and scan                   | S3, ECR, SSM, SES, Logs            |
| CodeDeploy   | Deploy to instances              | EC2, ELB, Auto Scaling             |

#### Secrets Management

All sensitive data stored in AWS Systems Manager Parameter Store:
- `/cicd/docker-credentials/username` (String)
- `/cicd/docker-credentials/password` (SecureString)
- `/cicd/docker-registry/url` (String)
- `/cicd/sonar/sonar-token` (SecureString)

### 6. Storage

#### S3 Buckets

**Artifacts Bucket**
- **Name**: blue-green-codebuild-artifacts-{account-id}
- **Purpose**: Pipeline artifacts, build outputs
- **Versioning**: Enabled
- **Encryption**: AES256
- **Lifecycle**: Delete after 30 days

**Reports Bucket**
- **Name**: blue-green-codebuild-{account-id}
- **Purpose**: Security scan reports
- **Versioning**: Enabled
- **Encryption**: AES256
- **Lifecycle**: Delete after 90 days

### 7. Monitoring & Notifications

#### CloudWatch

**Log Groups**
- `/aws/codebuild/blue-green-devsecops` (7 days retention)

**Alarms**
- Build failures (triggers on any failed build)

#### SNS

**Topic**: blue-green-devsecops-pipeline-notifications
- Pipeline state changes (SUCCESS/FAILURE)
- CodeBuild state changes
- Build failure alarms

#### SES

**Verified Identity**: Notification email
- Pipeline notifications
- Build status emails

## Data Flow

### 1. Development Flow

```
Developer → Git Push → GitHub → CodePipeline Trigger
```

### 2. Build Flow

```
CodePipeline → CodeBuild → Security Scans → Docker Build → 
Docker Hub → Reports to S3 → SonarQube Analysis
```

### 3. Deployment Flow

```
CodeBuild → CodeDeploy → Deploy to Green → Health Check → 
Switch ALB Traffic → Green becomes Active
```

### 4. Traffic Flow

```
User → Internet → ALB (Port 80) → Target Group (Blue/Green) → 
EC2 Instances (Port 3000) → Application
```

### 5. Security Scan Flow

```
Source Code → Trivy File Scan → Docker Build → Trivy Image Scan → 
OWASP Dependency Check → SonarQube Analysis → Reports to S3
```

## High Availability

### Multi-AZ Deployment
- Resources distributed across 2 availability zones
- ALB automatically routes to healthy targets
- NAT Gateways in each AZ for redundancy

### Auto-Recovery
- CodeDeploy automatic rollback on failure
- ALB health checks (30-second intervals)
- CloudWatch alarms for monitoring

### Blue-Green Strategy
- Zero-downtime deployments
- Instant rollback capability
- Traffic switching at load balancer level

## Scalability

### Current Capacity
- 4 application instances (2 Blue + 2 Green)
- Supports ~1000 concurrent users (estimated)
- Can handle ~100 requests/second (estimated)

### Scaling Options

**Vertical Scaling**
- Increase instance type (t3.medium → t3.large)
- Modify in terraform.tfvars

**Horizontal Scaling**
- Add more instances per environment
- Implement Auto Scaling Groups (future enhancement)

**Database Scaling**
- Add RDS for persistent data (future enhancement)
- Implement read replicas

## Cost Estimation

### Monthly Costs (Approximate)

| Service          | Resource                | Cost/Month |
|------------------|-------------------------|------------|
| EC2              | 5 × t3.medium (24/7)    | ~$150      |
| ALB              | 1 × Application LB      | ~$25       |
| NAT Gateway      | 2 × NAT Gateway         | ~$65       |
| S3               | Storage + Requests      | ~$5        |
| Data Transfer    | Outbound data           | ~$10       |
| CodePipeline     | 1 pipeline              | Free       |
| CodeBuild        | Build minutes           | ~$10       |
| CodeDeploy       | Deployments             | Free       |
| CloudWatch       | Logs + Alarms           | ~$5        |
| **Total**        |                         | **~$270**  |

**Note**: Costs vary based on usage. Use AWS Cost Calculator for accurate estimates.

### Cost Optimization Tips

1. **Stop non-production instances** when not in use
2. **Use Spot Instances** for non-critical workloads
3. **Enable S3 lifecycle policies** (already configured)
4. **Use CloudWatch Logs retention** (already set to 7 days)
5. **Consider Reserved Instances** for long-term usage

## Security Best Practices

### Implemented
✅ All data encrypted at rest (S3, EBS)  
✅ Secrets in Parameter Store (encrypted)  
✅ Security groups with least privilege  
✅ Private subnets for sensitive workloads  
✅ IAM roles with minimal permissions  
✅ Automated security scanning (Trivy, OWASP)  
✅ Code quality analysis (SonarQube)  

### Recommended Enhancements
- [ ] Enable AWS WAF on ALB
- [ ] Implement HTTPS with ACM certificates
- [ ] Enable VPC Flow Logs
- [ ] Add AWS GuardDuty
- [ ] Implement AWS Config rules
- [ ] Enable CloudTrail logging
- [ ] Add AWS Secrets Manager for rotation
- [ ] Implement network ACLs

## Disaster Recovery

### Backup Strategy
- **S3**: Versioning enabled, lifecycle policies
- **EC2**: AMI snapshots (manual or automated)
- **Configuration**: Terraform state (version controlled)

### Recovery Procedures

**Scenario 1: Failed Deployment**
- Automatic rollback via CodeDeploy
- Manual traffic switch to Blue environment

**Scenario 2: Instance Failure**
- ALB automatically routes to healthy instances
- Replace failed instance via Terraform

**Scenario 3: AZ Failure**
- Traffic automatically routes to other AZ
- Resources in second AZ remain operational

**Scenario 4: Complete Infrastructure Loss**
- Restore from Terraform configuration
- Deploy time: ~15 minutes

## Performance Optimization

### Current Optimizations
- Multi-AZ deployment for low latency
- ALB connection draining (30 seconds)
- EBS volumes with gp3 (better performance)
- CodeBuild in VPC (faster Docker pulls)

### Future Enhancements
- CloudFront CDN for static assets
- ElastiCache for session management
- RDS read replicas for database
- Auto Scaling based on metrics

## Compliance & Governance

### Tagging Strategy
All resources tagged with:
- `Project`: blue-green-devsecops
- `Environment`: production
- `ManagedBy`: Terraform

### Audit Trail
- CloudWatch Logs for all services
- CodePipeline execution history
- S3 access logs (can be enabled)
- CloudTrail (recommended to enable)

---

**Architecture Version**: 1.0  
**Last Updated**: November 2025  
**Region**: ap-south-1 (Mumbai)  
**Maintained By**: DevOps Team
