#!/bin/bash

# Script to log all instance variables and connection details
# Usage: ./log-instance-variables.sh

LOG_FILE="instance-variables.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

echo "=============================================" | tee -a $LOG_FILE
echo "Instance Variables Log - $TIMESTAMP" | tee -a $LOG_FILE
echo "=============================================" | tee -a $LOG_FILE

# Function to log with timestamp
log_with_timestamp() {
    echo "[$TIMESTAMP] $1" | tee -a $LOG_FILE
}

# Function to safely get terraform output
get_terraform_output() {
    local output_name=$1
    if terraform output $output_name 2>/dev/null; then
        return 0
    else
        echo "N/A (run terraform output $output_name)"
        return 1
    fi
}

echo "" | tee -a $LOG_FILE
echo "=== TERRAFORM OUTPUTS ===" | tee -a $LOG_FILE

# Get Terraform outputs
log_with_timestamp "Getting Terraform outputs..."

EC2_INSTANCE_ID=$(get_terraform_output instance_id 2>/dev/null | tr -d '"')
EC2_PUBLIC_IP=$(get_terraform_output instance_public_ip 2>/dev/null | tr -d '"')
EC2_PUBLIC_DNS=$(get_terraform_output instance_public_dns 2>/dev/null | tr -d '"')
KEY_PAIR_NAME=$(get_terraform_output key_pair_name 2>/dev/null | tr -d '"')
IAM_ROLE_ARN=$(get_terraform_output iam_role_arn 2>/dev/null | tr -d '"')

echo "EC2_INSTANCE_ID=$EC2_INSTANCE_ID" | tee -a $LOG_FILE
echo "EC2_PUBLIC_IP=$EC2_PUBLIC_IP" | tee -a $LOG_FILE
echo "EC2_PUBLIC_DNS=$EC2_PUBLIC_DNS" | tee -a $LOG_FILE
echo "KEY_PAIR_NAME=$KEY_PAIR_NAME" | tee -a $LOG_FILE
echo "IAM_ROLE_ARN=$IAM_ROLE_ARN" | tee -a $LOG_FILE

echo "" | tee -a $LOG_FILE
echo "=== SSH CONNECTION DETAILS ===" | tee -a $LOG_FILE

if [ "$EC2_PUBLIC_IP" != "N/A" ] && [ ! -z "$EC2_PUBLIC_IP" ]; then
    SSH_COMMAND="ssh -i pin.pem ubuntu@$EC2_PUBLIC_IP"
    echo "SSH_COMMAND=$SSH_COMMAND" | tee -a $LOG_FILE
    
    # Test SSH connectivity (optional)
    echo "" | tee -a $LOG_FILE
    log_with_timestamp "Testing SSH connectivity..."
    if ssh -i pin.pem -o ConnectTimeout=5 -o StrictHostKeyChecking=no ubuntu@$EC2_PUBLIC_IP "echo 'SSH connection successful'" 2>/dev/null; then
        echo "SSH_STATUS=CONNECTED" | tee -a $LOG_FILE
    else
        echo "SSH_STATUS=NOT_CONNECTED (check key file and security groups)" | tee -a $LOG_FILE
    fi
else
    echo "SSH_COMMAND=N/A (EC2 instance not ready or terraform not applied)" | tee -a $LOG_FILE
fi

echo "" | tee -a $LOG_FILE
echo "=== AWS CONFIGURATION ===" | tee -a $LOG_FILE

# Get AWS configuration
AWS_REGION=$(aws configure get region 2>/dev/null || echo "us-east-1")
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text 2>/dev/null || echo "N/A")
AWS_USER_ARN=$(aws sts get-caller-identity --query Arn --output text 2>/dev/null || echo "N/A")

echo "AWS_REGION=$AWS_REGION" | tee -a $LOG_FILE
echo "AWS_ACCOUNT_ID=$AWS_ACCOUNT_ID" | tee -a $LOG_FILE
echo "AWS_USER_ARN=$AWS_USER_ARN" | tee -a $LOG_FILE

echo "" | tee -a $LOG_FILE
echo "=== EKS CLUSTER DETAILS ===" | tee -a $LOG_FILE

# EKS Cluster information
CLUSTER_NAME="eks-mundos-e"
echo "CLUSTER_NAME=$CLUSTER_NAME" | tee -a $LOG_FILE

# Check if cluster exists
if aws eks describe-cluster --name $CLUSTER_NAME --region $AWS_REGION >/dev/null 2>&1; then
    CLUSTER_STATUS=$(aws eks describe-cluster --name $CLUSTER_NAME --region $AWS_REGION --query 'cluster.status' --output text 2>/dev/null)
    CLUSTER_ENDPOINT=$(aws eks describe-cluster --name $CLUSTER_NAME --region $AWS_REGION --query 'cluster.endpoint' --output text 2>/dev/null)
    CLUSTER_VERSION=$(aws eks describe-cluster --name $CLUSTER_NAME --region $AWS_REGION --query 'cluster.version' --output text 2>/dev/null)
    
    echo "CLUSTER_STATUS=$CLUSTER_STATUS" | tee -a $LOG_FILE
    echo "CLUSTER_ENDPOINT=$CLUSTER_ENDPOINT" | tee -a $LOG_FILE
    echo "CLUSTER_VERSION=$CLUSTER_VERSION" | tee -a $LOG_FILE
    
    # Get node group info
    NODE_GROUPS=$(aws eks list-nodegroups --cluster-name $CLUSTER_NAME --region $AWS_REGION --query 'nodegroups' --output text 2>/dev/null)
    echo "NODE_GROUPS=$NODE_GROUPS" | tee -a $LOG_FILE
else
    echo "CLUSTER_STATUS=NOT_FOUND" | tee -a $LOG_FILE
    echo "CLUSTER_ENDPOINT=N/A" | tee -a $LOG_FILE
    echo "CLUSTER_VERSION=N/A" | tee -a $LOG_FILE
fi

echo "" | tee -a $LOG_FILE
echo "=== KUBECTL CONFIGURATION ===" | tee -a $LOG_FILE

# Update kubeconfig
log_with_timestamp "Updating kubeconfig for EKS cluster..."
if aws eks update-kubeconfig --region $AWS_REGION --name $CLUSTER_NAME >/dev/null 2>&1; then
    echo "KUBECONFIG_STATUS=UPDATED" | tee -a $LOG_FILE
    
    # Test kubectl connectivity
    if kubectl get nodes >/dev/null 2>&1; then
        NODE_COUNT=$(kubectl get nodes --no-headers 2>/dev/null | wc -l)
        echo "KUBECTL_STATUS=CONNECTED" | tee -a $LOG_FILE
        echo "NODE_COUNT=$NODE_COUNT" | tee -a $LOG_FILE
        
        # Get node details
        echo "NODES_DETAILS:" | tee -a $LOG_FILE
        kubectl get nodes -o wide 2>/dev/null | tee -a $LOG_FILE
    else
        echo "KUBECTL_STATUS=NOT_CONNECTED" | tee -a $LOG_FILE
        echo "NODE_COUNT=0" | tee -a $LOG_FILE
    fi
else
    echo "KUBECONFIG_STATUS=FAILED" | tee -a $LOG_FILE
fi

echo "" | tee -a $LOG_FILE
echo "=== ENVIRONMENT VARIABLES FOR COPY-PASTE ===" | tee -a $LOG_FILE

# Create environment variables for easy copy-paste
echo "# Copy these variables to your shell:" | tee -a $LOG_FILE
echo "export EC2_PUBLIC_IP=\"$EC2_PUBLIC_IP\"" | tee -a $LOG_FILE
echo "export EC2_INSTANCE_ID=\"$EC2_INSTANCE_ID\"" | tee -a $LOG_FILE
echo "export CLUSTER_NAME=\"$CLUSTER_NAME\"" | tee -a $LOG_FILE
echo "export AWS_REGION=\"$AWS_REGION\"" | tee -a $LOG_FILE
echo "export SSH_COMMAND=\"$SSH_COMMAND\"" | tee -a $LOG_FILE

echo "" | tee -a $LOG_FILE
echo "=== QUICK REFERENCE COMMANDS ===" | tee -a $LOG_FILE

echo "# SSH to EC2 instance:" | tee -a $LOG_FILE
echo "$SSH_COMMAND" | tee -a $LOG_FILE
echo "" | tee -a $LOG_FILE

echo "# Connect to EKS cluster:" | tee -a $LOG_FILE
echo "aws eks update-kubeconfig --region $AWS_REGION --name $CLUSTER_NAME" | tee -a $LOG_FILE
echo "kubectl get nodes" | tee -a $LOG_FILE
echo "" | tee -a $LOG_FILE

echo "# Deploy NGINX:" | tee -a $LOG_FILE
echo "kubectl create deployment nginx-deployment --image=nginx:latest --replicas=2" | tee -a $LOG_FILE
echo "kubectl expose deployment nginx-deployment --port=80 --target-port=80 --type=LoadBalancer" | tee -a $LOG_FILE
echo "" | tee -a $LOG_FILE

echo "# Check NGINX service:" | tee -a $LOG_FILE
echo "kubectl get service nginx-deployment" | tee -a $LOG_FILE
echo "kubectl get pods -l app=nginx-deployment" | tee -a $LOG_FILE

echo "" | tee -a $LOG_FILE
echo "=== LOG SUMMARY ===" | tee -a $LOG_FILE
log_with_timestamp "Instance variables logged to $LOG_FILE"
echo "=============================================" | tee -a $LOG_FILE

# Display summary
echo ""
echo "Summary of key variables:"
echo "------------------------"
echo "EC2 Public IP: $EC2_PUBLIC_IP"
echo "SSH Command: $SSH_COMMAND"
echo "EKS Cluster: $CLUSTER_NAME"
echo "AWS Region: $AWS_REGION"
echo ""
echo "Full details saved to: $LOG_FILE"
echo ""

# Create a source-able variables file
VARS_FILE="instance-vars.env"
cat > $VARS_FILE << EOF
# Instance Variables - Generated on $TIMESTAMP
export EC2_PUBLIC_IP="$EC2_PUBLIC_IP"
export EC2_INSTANCE_ID="$EC2_INSTANCE_ID"
export EC2_PUBLIC_DNS="$EC2_PUBLIC_DNS"
export CLUSTER_NAME="$CLUSTER_NAME"
export AWS_REGION="$AWS_REGION"
export SSH_COMMAND="$SSH_COMMAND"
export KEY_PAIR_NAME="$KEY_PAIR_NAME"
EOF

echo "Environment variables file created: $VARS_FILE"
echo "Source it with: source $VARS_FILE"