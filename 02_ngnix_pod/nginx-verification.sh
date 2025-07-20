#!/bin/bash

echo "=== Checking Pod Status ==="
kubectl get pods -l app=nginx

echo "=== Checking Service Status ==="
kubectl get services

echo "=== Getting Service Details ==="
kubectl describe service nginx-service

echo "=== Getting External IP/Hostname ==="
EXTERNAL_IP=$(kubectl get service nginx-service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo "External Hostname: $EXTERNAL_IP"

if [ ! -z "$EXTERNAL_IP" ]; then
    echo "=== Testing NGINX Response ==="
    echo "Waiting for LoadBalancer to be ready..."
    sleep 60
    curl -I http://$EXTERNAL_IP || echo "LoadBalancer might still be provisioning"
    
    echo "=== You can also test in browser ==="
    echo "Open: http://$EXTERNAL_IP"
else
    echo "LoadBalancer is still provisioning. Check again in a few minutes with:"
    echo "kubectl get service nginx-service"
fi

echo "=== Pod Logs ==="
kubectl logs -l app=nginx --tail=10