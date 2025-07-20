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

echo "This script will completely clean up ALL resources created for the DevOps Integrator project."
echo "WARNING: This action is IRREVERSIBLE and will delete:"
echo "  - EKS Cluster and all workloads"
echo "  - EC2 instances created by Terraform"
echo "  - All persistent volumes and data"
echo "  - LoadBalancers and associated AWS resources"
echo "  - IAM roles and policies"
echo "  - Security groups"
echo "  - Key pairs"
echo ""

if ! confirm "Are you absolutely sure you want to proceed?"; then
    echo "Cleanup cancelled by user."
    exit 0
fi

echo ""
echo "Starting cleanup process..."
echo ""

# 1. KUBERNETES CLEANUP
echo "=========================================="
echo "STEP 1: CLEANING UP KUBERNETES RESOURCES"
echo "=========================================="

if command_exists kubectl && kubectl cluster-info >/dev/null 2>&1; then
    echo "Kubernetes cluster detected. Starting cleanup..."
    
    # Delete Grafana
    echo "Deleting Grafana..."
    helm uninstall grafana -n grafana 2>/dev/null || echo "Grafana not found or already deleted"
    kubectl delete namespace grafana 2>/dev/null || echo "Grafana namespace not found"
    
    # Delete Prometheus
    echo "Deleting Prometheus..."
    helm uninstall prometheus -n prometheus 2>/dev/null || echo "Prometheus not found or already deleted"
    kubectl delete namespace prometheus 2>/dev/null || echo "Prometheus namespace not found"
    
    # Delete nginx deployment
    echo "Deleting nginx deployment..."
    kubectl delete -f nginx-deployment.yaml 2>/dev/null || echo "Nginx deployment not found"
    
    # Delete test PVC if exists
    echo "Deleting test resources..."
    kubectl delete pvc test-ebs-claim 2>/dev/null || echo "Test PVC not found"
    kubectl delete -f test-pvc.yaml 2>/dev/null || echo "Test PVC file not found"
    
    # Delete custom storage class
    echo "Deleting custom storage classes..."
    kubectl delete storageclass ebs-sc 2>/dev/null || echo "Custom storage class not found"
    
    # Delete EBS CSI driver
    echo "Deleting EBS CSI driver..."
    kubectl delete -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=release-1.20" 2>/dev/null || echo "EBS CSI driver not found or already deleted"
    
    # Wait for LoadBalancers to be deleted
    echo "Waiting for LoadBalancers to be terminated..."
    sleep 30
    
    echo "Kubernetes resources cleanup completed."
else
    echo "No Kubernetes cluster found or kubectl not available."
fi

echo ""

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

# 3. TERRAFORM CLEANUP
echo "=========================================="
echo "STEP 3: TERRAFORM INFRASTRUCTURE CLEANUP"
echo "=========================================="

if command_exists terraform && [ -f "main.tf" ]; then
    echo "Terraform configuration detected. Destroying infrastructure..."
    
    # Initialize terraform if needed
    if [ ! -d ".terraform" ]; then
        echo "Initializing Terraform..."
        terraform init
    fi
    
    echo "Destroying Terraform-managed resources..."
    terraform destroy -auto-approve
    
    if [ $? -eq 0 ]; then
        echo "Terraform resources destroyed successfully."
    else
        echo "ERROR: Some Terraform resources may not have been destroyed. Please check manually."
    fi
    
    # Clean terraform state and cache
    echo "Cleaning Terraform state files..."
    rm -rf .terraform
    rm -f terraform.tfstate*
    rm -f .terraform.lock.hcl
    
else
    echo "No Terraform configuration found or terraform not installed."
fi

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

echo ""

# 5. LOCAL CLEANUP
echo "=========================================="
echo "STEP 5: LOCAL FILE CLEANUP"
echo "=========================================="

echo "Cleaning up local files..."

# Remove key files
if [ -f "pin.pem" ]; then
    rm -f pin.pem
    echo "Removed pin.pem"
fi

if [ -f "pin.pub" ]; then
    rm -f pin.pub
    echo "Removed pin.pub"
fi

# Remove kubectl config context
if command_exists kubectl; then
    kubectl config delete-context arn:aws:eks:$AWS_REGION:*:cluster/$CLUSTER_NAME 2>/dev/null || echo "Cluster context not found in kubectl config"
fi

# Remove helm repositories
if command_exists helm; then
    echo "Removing Helm repositories..."
    helm repo remove prometheus-community 2>/dev/null || echo "Prometheus repo not found"
    helm repo remove grafana 2>/dev/null || echo "Grafana repo not found"
fi

echo ""

# 6. FINAL SUMMARY
echo "=========================================="
echo "CLEANUP SUMMARY"
echo "=========================================="

echo "✅ Kubernetes resources (Grafana, Prometheus, nginx) - Attempted cleanup"
echo "✅ EKS cluster deletion - Attempted"
echo "✅ Terraform infrastructure - Attempted cleanup"
echo "✅ Local files and configurations - Cleaned"
echo "✅ Helm repositories - Removed"

echo ""
echo "=========================================="
echo "MANUAL VERIFICATION REQUIRED"
echo "=========================================="
echo ""
echo "Please manually verify in AWS Console that all resources are deleted:"
echo "1. EC2 Dashboard - Check for remaining instances"
echo "2. EBS Dashboard - Check for unattached volumes"
echo "3. Load Balancers - Verify no ALB/NLB remain"
echo "4. IAM Roles - Check for eksctl-created roles"
echo "5. VPC Dashboard - Verify no orphaned security groups"
echo "6. CloudFormation - Check for remaining stacks"
echo ""
echo "AWS Console URL: https://console.aws.amazon.com/"
echo ""

echo "=========================================="
echo "ESTIMATED COST IMPACT"
echo "=========================================="
echo "After this cleanup, you should have minimal ongoing AWS costs."
echo "Any remaining charges would be from:"
echo "- Undeleted EBS volumes"
echo "- Running EC2 instances"
echo "- Active LoadBalancers"
echo ""

if confirm "Would you like to see current AWS costs estimate?"; then
    if command_exists aws; then
        echo "Getting current month cost estimate..."
        aws ce get-cost-and-usage \
            --time-period Start=$(date -d "$(date +%Y-%m-01)" +%Y-%m-%d),End=$(date +%Y-%m-%d) \
            --granularity MONTHLY \
            --metrics BlendedCost \
            --region us-east-1 2>/dev/null || echo "Unable to retrieve cost information."
    fi
fi

echo ""
echo "🎉 CLEANUP PROCESS COMPLETED!"
echo "Thank you for using the DevOps Integrator project cleanup script."
echo ""