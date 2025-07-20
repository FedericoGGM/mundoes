#!/bin/bash
# Deploy Grafana using the provided grafana.yaml configuration

echo "Adding Grafana Helm repository..."
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

echo "Creating grafana namespace..."
kubectl create namespace grafana

echo "Installing Grafana with custom configuration..."
helm install grafana grafana/grafana \
    --namespace grafana \
    --set persistence.storageClassName="gp2" \
    --set persistence.enabled=true \
    --set persistence.size="10Gi" \
    --set adminPassword='EKS!sAWSome' \
    --values grafana.yaml \
    --set service.type=LoadBalancer \
    --set service.port=80

echo "Waiting for Grafana to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=grafana -n grafana --timeout=300s

echo "Getting Grafana service information..."
kubectl get svc -n grafana

echo "Grafana installation complete!"
echo "Admin password: EKS!sAWSome"
echo "To get LoadBalancer URL, run: kubectl get svc grafana -n grafana"
echo "Prometheus datasource is already configured via grafana.yaml"