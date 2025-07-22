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