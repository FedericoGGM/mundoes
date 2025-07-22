#!/bin/bash

echo "=========================================="
echo "COMPLETE DEVOPS INTEGRATOR PROJECT CLEANUP"
echo "=========================================="

# Variables - Update these to match your configuration
CLUSTER_NAME="eks-mundos-e"
AWS_REGION="us-east-1"
KEY_PAIR_NAME="pin"
PROJECT_NAME="devops-integrator"

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to wait for user confirmation
confirm() {
    read -p "$1 (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        return 0
    else
        return 1
    fi
}


if ! confirm "Are you absolutely sure you want to proceed?"; then
    echo "Cleanup cancelled by user."
    exit 0
fi

echo ""
echo "Starting cleanup process..."
echo ""

# 4. AWS CLEANUP (Manual verification)
echo "=========================================="
echo "STEP 4: AWS RESOURCES VERIFICATION"
echo "=========================================="

if command_exists aws; then
    echo "Checking for remaining AWS resources..."
    
    # Check for remaining EC2 instances
    echo "Checking EC2 instances with project tag..."
    aws ec2 describe-instances \
        --filters "Name=tag:Project,Values=$PROJECT_NAME" "Name=instance-state-name,Values=running,pending,stopping,stopped" \
        --query 'Reservations[*].Instances[*].[InstanceId,State.Name,Tags[?Key==`Name`].Value|[0]]' \
        --output table --region $AWS_REGION 2>/dev/null || echo "No tagged EC2 instances found."
    
    # Check for remaining EBS volumes
    echo "Checking EBS volumes..."
    aws ec2 describe-volumes \
        --filters "Name=tag:Project,Values=$PROJECT_NAME" \
        --query 'Volumes[*].[VolumeId,State,Size,Tags[?Key==`Name`].Value|[0]]' \
        --output table --region $AWS_REGION 2>/dev/null || echo "No tagged EBS volumes found."
    
    # Check for LoadBalancers
    echo "Checking for remaining LoadBalancers..."
    aws elbv2 describe-load-balancers \
        --query 'LoadBalancers[?contains(LoadBalancerName, `grafana`) || contains(LoadBalancerName, `prometheus`)][LoadBalancerName,State.Code]' \
        --output table --region $AWS_REGION 2>/dev/null || echo "No LoadBalancers found."
    
    # Check for Security Groups
    echo "Checking Security Groups..."
    aws ec2 describe-security-groups \
        --filters "Name=tag:Project,Values=$PROJECT_NAME" \
        --query 'SecurityGroups[*].[GroupId,GroupName]' \
        --output table --region $AWS_REGION 2>/dev/null || echo "No tagged security groups found."
    
    # Check for Key Pairs
    echo "Checking Key Pairs..."
    aws ec2 describe-key-pairs \
        --key-names $KEY_PAIR_NAME \
        --query 'KeyPairs[*].[KeyName,KeyPairId]' \
        --output table --region $AWS_REGION 2>/dev/null || echo "Key pair not found."
        
else
    echo "AWS CLI not found. Please verify remaining resources manually in AWS Console."
fi
