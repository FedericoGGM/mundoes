I'll help you deploy an NGINX pod to your EKS cluster and verify it's working. Based on your setup, you have an EC2 instance with all the necessary tools installed and an EKS cluster created. Here are several methods to deploy NGINX:

## Method 1: Using kubectl (Recommended)

First, SSH into your EC2 instance and ensure you can connect to your EKS cluster:

```bash
# SSH into your EC2 instance
ssh -i pin.pem ubuntu@<your-ec2-public-ip>

# Verify cluster connectivity
kubectl get nodes
```

Now deploy NGINX using one of these approaches:

### Option A: Simple Pod Deployment

### Option B: Deployment with Service (Better for production)

### Deploy using kubectl:

```bash
# Create the deployment (choose one of the above YAML files)
kubectl apply -f nginx-deployment.yaml
kubectl apply -f nginx-pod.yaml

# Or deploy directly without YAML file
kubectl create deployment nginx-deployment --image=nginx:latest --replicas=2
kubectl expose deployment nginx-deployment --port=80 --target-port=80 --type=LoadBalancer
```

## Method 2: Using AWS Console

1. Go to **Amazon EKS** in AWS Console
2. Select your cluster `eks-mundos-e`
3. Go to **Workloads** tab
4. Click **Create** and choose **Deployment**
5. Configure:
   - Name: `nginx-deployment`
   - Image: `nginx:latest`
   - Replicas: `2`
   - Port: `80`
6. Create a **Service** with type `LoadBalancer`

## Method 3: Using Helm

```bash
# Install NGINX using Helm chart
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install nginx-ingress ingress-nginx/ingress-nginx
```

## Verification Steps

After deployment, verify NGINX is running:


## Complete Step-by-Step Process

1. **SSH into your EC2 instance:**
   ```bash
   ssh -i pin.pem ubuntu@<your-ec2-ip>
   ```

2. **Verify cluster access:**
   ```bash
   kubectl get nodes
   kubectl get namespaces
   ```

3. **Deploy NGINX:** (using the deployment method)
   ```bash
   # Create the YAML file
   cat << 'EOF' > nginx-deployment.yaml
   # Copy content from the nginx-deployment.yaml artifact above
   EOF
   
   # Apply the deployment
   kubectl apply -f nginx-deployment.yaml
   ```

4. **Wait for deployment:**
   ```bash
   kubectl get pods -w
   # Wait until pods show "Running" status
   ```

5. **Get the LoadBalancer hostname:**
   ```bash
   kubectl get service nginx-service
   # Wait for EXTERNAL-IP to show (may take 2-3 minutes)
   ```

6. **Test NGINX:**
   ```bash
   # Get the hostname
   NGINX_HOST=$(kubectl get service nginx-service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
   echo "NGINX URL: http://$NGINX_HOST"
   
   # Test with curl
   curl http://$NGINX_HOST
   ```

7. **Verify in browser:**
   - Open the URL in your browser to see the NGINX welcome page

The LoadBalancer will create an AWS ELB that provides external access to your NGINX pods. The hostname will be something like `abc123-123456789.us-east-1.elb.amazonaws.com`.

Which method would you prefer to use? I recommend starting with the kubectl deployment method as it's most straightforward and gives you good visibility into the process.