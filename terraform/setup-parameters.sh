#!/bin/bash

# Script to set up AWS Systems Manager Parameter Store values
# Run this script after creating the infrastructure

set -e

echo "=========================================="
echo "Setting up AWS Systems Manager Parameters"
echo "=========================================="

# Configuration
AWS_REGION="ap-south-1"

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "Error: AWS CLI is not installed. Please install it first."
    exit 1
fi

# Function to create or update parameter
create_parameter() {
    local param_name=$1
    local param_value=$2
    local param_type=$3
    
    echo "Creating parameter: $param_name"
    aws ssm put-parameter \
        --name "$param_name" \
        --value "$param_value" \
        --type "$param_type" \
        --overwrite \
        --region "$AWS_REGION" \
        --no-cli-pager
}

# Prompt for Docker credentials
echo ""
echo "Enter your Docker Hub credentials:"
read -p "Docker Hub Username: " DOCKER_USERNAME
read -sp "Docker Hub Password: " DOCKER_PASSWORD
echo ""

# Prompt for Docker Registry URL
read -p "Docker Registry URL (default: docker.io): " DOCKER_REGISTRY_URL
DOCKER_REGISTRY_URL=${DOCKER_REGISTRY_URL:-docker.io}

# Prompt for SonarQube token (optional at this stage)
echo ""
echo "SonarQube Token (leave empty if not yet generated):"
read -sp "SonarQube Token: " SONAR_TOKEN
echo ""

# Create parameters
echo ""
echo "Creating parameters in AWS Systems Manager..."

create_parameter "/cicd/docker-credentials/username" "$DOCKER_USERNAME" "String"
create_parameter "/cicd/docker-credentials/password" "$DOCKER_PASSWORD" "SecureString"
create_parameter "/cicd/docker-registry/url" "$DOCKER_REGISTRY_URL" "String"

if [ -n "$SONAR_TOKEN" ]; then
    create_parameter "/cicd/sonar/sonar-token" "$SONAR_TOKEN" "SecureString"
else
    echo "Skipping SonarQube token (not provided)"
fi

echo ""
echo "=========================================="
echo "Parameters created successfully!"
echo "=========================================="
echo ""
echo "Note: If you skipped the SonarQube token, you can add it later using:"
echo "aws ssm put-parameter --name /cicd/sonar/sonar-token --value YOUR_TOKEN --type SecureString --region $AWS_REGION"
