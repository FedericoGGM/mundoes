#!/bin/bash

# Script to run inside EC2 instance to gather internal variables
# Upload this to your EC2 instance and run it there

LOG_FILE="ec2-internal-variables.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

echo "=============================================" | tee -a $LOG_FILE
echo "EC2 Internal Variables Log - $TIMESTAMP" | tee -a $LOG_FILE
echo "=============================================" | tee -a $LOG_FILE

echo "" | tee -a $LOG_FILE
echo "=== EC2 METADATA ===" | tee -a $LOG_FILE

# Get EC2 metadata
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
AVAILABILITY_ZONE=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
INSTANCE_TYPE=$(curl -s http://169.254.169.254/latest/meta-data/instance-type)
PUBLIC_HOSTNAME=$(curl -s http://169.254.169.254/latest/meta-data/public-hostname)
PRIVATE_HOSTNAME=$(curl -s http://169.254.169.254/latest/meta-data/local-hostname)

echo "INSTANCE_ID=$INSTANCE_ID" | tee -a $LOG_FILE
echo "PUBLIC_IP=$PUBLIC_IP" | tee -a $LOG_FILE
echo "PRIVATE_IP=$PRIVATE_IP" | tee -a $LOG_FILE
echo "PUBLIC_HOSTNAME=$PUBLIC_HOSTNAME" | tee -a $LOG_FILE
echo "PRIVATE_HOSTNAME=$PRIVATE_HOSTNAME" | tee -a $LOG_FILE
echo "AVAILABILITY_ZONE=$AVAILABILITY_ZONE" | tee -a $LOG_FILE
echo "INSTANCE_TYPE=$INSTANCE_TYPE" | tee -a $LOG_FILE

echo "" | tee -a $LOG_FILE
echo "=== SYSTEM INFORMATION ===" | tee -a $LOG_FILE

OS_VERSION=$(lsb_release -d | cut -f2)
KERNEL_VERSION=$(uname -r)
HOSTNAME=$(hostname)
UPTIME=$(uptime | cut -d',' -f1)

echo "OS_VERSION=$OS_VERSION" | tee -a $LOG_FILE
echo "KERNEL_VERSION=$KERNEL_VERSION" | tee -a $LOG_FILE
echo "HOSTNAME=$HOSTNAME" | tee -a $LOG_FILE
echo "UPTIME=$UPTIME" | tee -a $LOG_FILE

echo "" | tee -a $LOG_FILE
echo "=== INSTALLED TOOLS VERSIONS ===" | tee -a $LOG_FILE

# Check tool versions
DOCKER_VERSION=$(docker --version 2>/dev/null || echo "Not installed")
KUBECTL_VERSION=$(kubectl version --client --short 2>/dev/null || echo "Not installed")
EKSCTL_VERSION=$(eksctl version 2>/dev/null || echo "Not installed")
HELM_VERSION=$(helm version --short 2>/dev/null || echo "Not installed")
TERRAFORM_VERSION=$(terraform version 2>/dev/null | head -n1 || echo "Not installed")
AWS_CLI_VERSION=$(aws --version 2>/dev/null || echo "Not installed")

echo "DOCKER_VERSION=$DOCKER_VERSION" | tee -a $LOG_FILE
echo "KUBECTL_VERSION=$KUBECTL_VERSION" | tee -a $LOG_FILE
echo "EKSCTL_VERSION=$EKSCTL_VERSION" | tee -a $LOG_FILE
echo "HELM_VERSION=$HELM_VERSION" | tee -a $LOG_FILE
echo "TERRAFORM_VERSION=$TERRAFORM_VERSION" | tee -a $LOG_FILE
echo "AWS_CLI_VERSION=$AWS_CLI_VERSION" | tee -a $LOG_FILE

echo "" | tee -a $LOG_FILE
echo "=== AWS CREDENTIALS STATUS ===" | tee -a $LOG_FILE

# Check AWS credentials
if aws sts get-caller-identity >/dev/null 2>&1; then
    AWS_IDENTITY=$(aws sts get-caller-identity 2>/dev/null)
    AWS_ACCOUNT=$(echo $AWS_IDENTITY | jq -r '.Account' 2>/dev/null || echo "N/A")
    AWS_USER_ARN=$(echo $AWS_IDENTITY | jq -r '.Arn' 2>/dev/null || echo "N/A")
    AWS_USER_ID=$(echo $AWS_IDENTITY | jq -r '.UserId' 2>/dev/null || echo "N/A")
    
    echo "AWS_CREDENTIALS_STATUS=VALID" | tee -a $LOG_FILE
    echo "AWS_ACCOUNT=$AWS_ACCOUNT" | tee -a $LOG_FILE
    echo "AWS_USER_ARN=$AWS_USER_ARN" | tee -a $LOG_FILE
    echo "AWS_USER_ID=$AWS_USER_ID" | tee -a $LOG_FILE
else
    echo "AWS_CREDENTIALS_STATUS=INVALID" | tee -a $LOG_FILE
fi

echo "" | tee -a $LOG_FILE
echo "=== DOCKER STATUS ===" | tee -a $LOG_FILE

if systemctl is-active --quiet docker; then
    echo "DOCKER_SERVICE_STATUS=RUNNING" | tee -a $LOG_FILE
    DOCKER_INFO=$(docker info --format "{{.ServerVersion}}" 2>/dev/null)
    echo "DOCKER_SERVER_VERSION=$DOCKER_INFO" | tee -a $LOG_FILE
    
    # Check if user is in docker group
    if groups $USER | grep -q docker; then
        echo "DOCKER_USER_ACCESS=GRANTED" | tee -a $LOG_FILE
    else
        echo "DOCKER_USER_ACCESS=DENIED (user not in docker group)" | tee -a $LOG_FILE
    fi
else
    echo "DOCKER_SERVICE_STATUS=NOT_RUNNING" | tee -a $LOG_FILE
fi

echo "" | tee -a $LOG_FILE
echo "=== KUBERNETES CLUSTER ACCESS ===" | tee -a $LOG_FILE

# Check kubectl access
if kubectl cluster-info >/dev/null 2>&1; then
    CLUSTER_INFO=$(kubectl cluster-info | head -n1)
    CURRENT_CONTEXT=$(kubectl config current-context 2>/dev/null)
    NODE_COUNT=$(kubectl get nodes --no-headers 2>/dev/null | wc -l)
    
    echo "KUBECTL_STATUS=CONNECTED" | tee -a $LOG_FILE
    echo "CURRENT_CONTEXT=$CURRENT_CONTEXT" | tee -a $LOG_FILE
    echo "NODE_COUNT=$NODE_COUNT" | tee -a $LOG_FILE
    echo "CLUSTER_INFO=$CLUSTER_INFO" | tee -a $LOG_FILE
    
    # List nodes
    echo "" | tee -a $LOG_FILE
    echo "CLUSTER_NODES:" | tee -a $LOG_FILE
    kubectl get nodes -o wide 2>/dev/null | tee -a $LOG_FILE
    
    # List running pods
    echo "" | tee -a $LOG_FILE
    echo "RUNNING_PODS:" | tee -a $LOG_FILE
    kubectl get pods --all-namespaces 2>/dev/null | tee -a $LOG_FILE
    
else
    echo "KUBECTL_STATUS=NOT_CONNECTED" | tee -a $LOG_FILE
fi

echo "" | tee -a $LOG_FILE
echo "=== NETWORK CONFIGURATION ===" | tee -a $LOG_FILE

# Network information
DEFAULT_GATEWAY=$(ip route | grep default | awk '{print $3}' | head -n1)
DNS_SERVERS=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}' | tr '\n' ',' | sed 's/,$//')

echo "DEFAULT_GATEWAY=$DEFAULT_GATEWAY" | tee -a $LOG_FILE
echo "DNS_SERVERS=$DNS_SERVERS" | tee -a $LOG_FILE

# Network interfaces
echo "" | tee -a $LOG_FILE
echo "NETWORK_INTERFACES:" | tee -a $LOG_FILE
ip addr show | grep -E "inet |^[0-9]+:" | tee -a $LOG_FILE

echo "" | tee -a $LOG_FILE
echo "=== ENVIRONMENT VARIABLES FOR SCRIPTS ===" | tee -a $LOG_FILE

# Create variables for use in deployment scripts
cat >> ec2-internal-vars.env << EOF
# EC2 Internal Variables - Generated on $TIMESTAMP
export INSTANCE_ID="$INSTANCE_ID"
export PUBLIC_IP="$PUBLIC_IP"
export PRIVATE_IP="$PRIVATE_IP"
export PUBLIC_HOSTNAME="$PUBLIC_HOSTNAME"
export PRIVATE_HOSTNAME="$PRIVATE_HOSTNAME"
export AVAILABILITY_ZONE="$AVAILABILITY_ZONE"
export INSTANCE_TYPE="$INSTANCE_TYPE"
export AWS_ACCOUNT="$AWS_ACCOUNT"
export CURRENT_CONTEXT="$CURRENT_CONTEXT"
export NODE_COUNT="$NODE_COUNT"
EOF

echo "# Environment variables saved to ec2-internal-vars.env" | tee -a $LOG_FILE
echo "# Source with: source ec2-internal-vars.env" | tee -a $LOG_FILE

echo "" | tee -a $LOG_FILE
echo "=== NGINX DEPLOYMENT READINESS CHECK ===" | tee -a $LOG_FILE

# Check if ready for NGINX deployment
READINESS_SCORE=0
TOTAL_CHECKS=5

echo "Checking deployment readiness..." | tee -a $LOG_FILE

# Check 1: AWS credentials
if aws sts get-caller-identity >/dev/null 2>&1; then
    echo "✓ AWS credentials configured" | tee -a $LOG_FILE
    ((READINESS_SCORE++))
else
    echo "✗ AWS credentials not configured" | tee -a $LOG_FILE
fi

# Check 2: kubectl connectivity
if kubectl get nodes >/dev/null 2>&1; then
    echo "✓ kubectl connected to EKS cluster" | tee -a $LOG_FILE
    ((READINESS_SCORE++))
else
    echo "✗ kubectl not connected to EKS cluster" | tee -a $LOG_FILE
fi

# Check 3: Nodes ready
if [ "$NODE_COUNT" -gt 0 ]; then
    echo "✓ EKS nodes available ($NODE_COUNT nodes)" | tee -a $LOG_FILE
    ((READINESS_SCORE++))
else
    echo "✗ No EKS nodes available" | tee -a $LOG_FILE
fi

# Check 4: Docker running
if systemctl is-active --quiet docker; then
    echo "✓ Docker service running" | tee -a $LOG_FILE
    ((READINESS_SCORE++))
else
    echo "✗ Docker service not running" | tee -a $LOG_FILE
fi

# Check 5: Internet connectivity
if ping -c 1 google.com >/dev/null 2>&1; then
    echo "✓ Internet connectivity available" | tee -a $LOG_FILE
    ((READINESS_SCORE++))
else
    echo "✗ No internet connectivity" | tee -a $LOG_FILE
fi

echo "" | tee -a $LOG_FILE
echo "READINESS_SCORE=$READINESS_SCORE/$TOTAL_CHECKS" | tee -a $LOG_FILE

if [ $READINESS_SCORE -eq $TOTAL_CHECKS ]; then
    echo "STATUS=READY_FOR_NGINX_DEPLOYMENT" | tee -a $LOG_FILE
    echo "🎉 System is ready for NGINX deployment!" | tee -a $LOG_FILE
else
    echo "STATUS=NOT_READY_FOR_DEPLOYMENT" | tee -a $LOG_FILE
    echo "⚠️  Fix the failed checks before deploying NGINX" | tee -a $LOG_FILE
fi

echo "=============================================" | tee -a $LOG_FILE
echo "Log saved to: $LOG_FILE"
echo "Variables saved to: ec2-internal-vars.env"