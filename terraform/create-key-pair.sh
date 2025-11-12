#!/bin/bash

# Script to create EC2 key pair for SSH access

set -e

echo "=========================================="
echo "Creating EC2 Key Pair"
echo "=========================================="

# Configuration
KEY_NAME="blue-green-key"
AWS_REGION="ap-south-1"
OUTPUT_FILE="${KEY_NAME}.pem"

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "Error: AWS CLI is not installed. Please install it first."
    exit 1
fi

# Check if key already exists
if aws ec2 describe-key-pairs --key-names "$KEY_NAME" --region "$AWS_REGION" &> /dev/null; then
    echo "Key pair '$KEY_NAME' already exists in AWS."
    read -p "Do you want to delete and recreate it? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Deleting existing key pair..."
        aws ec2 delete-key-pair --key-name "$KEY_NAME" --region "$AWS_REGION"
    else
        echo "Keeping existing key pair. Exiting."
        exit 0
    fi
fi

# Create new key pair
echo "Creating new key pair: $KEY_NAME"
aws ec2 create-key-pair \
    --key-name "$KEY_NAME" \
    --region "$AWS_REGION" \
    --query 'KeyMaterial' \
    --output text > "$OUTPUT_FILE"

# Set proper permissions
chmod 400 "$OUTPUT_FILE"

echo ""
echo "=========================================="
echo "Key pair created successfully!"
echo "=========================================="
echo "Key Name: $KEY_NAME"
echo "Private Key File: $OUTPUT_FILE"
echo ""
echo "IMPORTANT: Keep this file safe! You'll need it to SSH into your EC2 instances."
echo "To use it: ssh -i $OUTPUT_FILE ec2-user@<instance-ip>"
