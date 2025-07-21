#!/bin/bash

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

# 2. EKS CLUSTER CLEANUP
echo "=========================================="
echo "STEP 2: DELETING EKS CLUSTER"
echo "=========================================="

if command_exists eksctl; then
    # Check if cluster exists
    if eksctl get cluster --name $CLUSTER_NAME --region $AWS_REGION >/dev/null 2>&1; then
        echo "Deleting EKS cluster: $CLUSTER_NAME"
        echo "This may take 10-15 minutes..."
        
        eksctl delete cluster --name $CLUSTER_NAME --region $AWS_REGION --wait
        
        if [ $? -eq 0 ]; then
            echo "EKS cluster deleted successfully."
        else
            echo "ERROR: Failed to delete EKS cluster. Please check manually in AWS Console."
        fi
    else
        echo "EKS cluster $CLUSTER_NAME not found or already deleted."
    fi
else
    echo "eksctl not found. Please delete EKS cluster manually from AWS Console."
fi

echo ""