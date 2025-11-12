variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "ap-south-1"
}

variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
  default     = "792840215332"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "blue-green-devsecops"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "instance_type" {
  description = "EC2 instance type for application servers"
  type        = string
  default     = "t3.medium"
}

variable "sonarqube_instance_type" {
  description = "EC2 instance type for SonarQube server"
  type        = string
  default     = "t3.medium"
}

variable "key_name" {
  description = "EC2 key pair name (must exist in AWS)"
  type        = string
  default     = "blue-green-key"
}

variable "github_repo" {
  description = "GitHub repository (format: owner/repo)"
  type        = string
  default     = "RiddheshRameshSutar/Blue-Green-DevSecOps"
}

variable "github_branch" {
  description = "GitHub branch to track"
  type        = string
  default     = "main"
}

variable "docker_registry_url" {
  description = "Docker registry URL"
  type        = string
  default     = "docker.io"
}

variable "docker_username" {
  description = "Docker Hub username"
  type        = string
  sensitive   = true
}

variable "docker_password" {
  description = "Docker Hub password"
  type        = string
  sensitive   = true
}

variable "sonar_token" {
  description = "SonarQube authentication token"
  type        = string
  sensitive   = true
  default     = ""
}

variable "notification_email" {
  description = "Email address for notifications"
  type        = string
  default     = "modveyash@gmail.com"
}

variable "s3_bucket_name" {
  description = "S3 bucket name for artifacts"
  type        = string
  default     = "blue-green-codebuild-artifacts"
}
