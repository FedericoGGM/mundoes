#!/bin/bash
# Deploy Prometheus using Helm with corrected storage class

echo "Adding Prometheus Helm repository..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

echo "Creating prometheus namespace..."
kubectl create namespace prometheus

echo "Installing Prometheus with EBS CSI driver support..."
helm install prometheus prometheus-community/prometheus \
    --namespace prometheus \
    --set alertmanager.persistentVolume.storageClass="gp2" \
    --set server.persistentVolume.storageClass="gp2" \
    --set alertmanager.persistentVolume.size="2Gi" \
    --set server.persistentVolume.size="8Gi"

echo "Waiting for Prometheus to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=prometheus -n prometheus --timeout=300s

echo "Checking Prometheus installation..."
kubectl get all -n prometheus

echo "Prometheus installation complete!"
echo "To access Prometheus, run: kubectl port-forward -n prometheus svc/prometheus-server 9090:80"