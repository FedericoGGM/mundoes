Perfect! Now I have the missing `grafana.yaml` file. Let me provide you with the correct EBS CSI driver installation and updated deployment scripts.

## Step 1: Install EBS CSI Driver (As Instructed)

First, install the EBS CSI driver using the specific method you were instructed to use:

```bash
# Install EBS CSI driver using kustomize
kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=release-1.20"
```

**Note**: This method installs the driver directly without IAM service accounts. For production, you'd want to use the IAM service account method I mentioned earlier, but this works for testing/development.

## Step 2: Verify EBS CSI Driver Installation

```bash
# Check if EBS CSI driver pods are running
kubectl get pods -n kube-system -l app=ebs-csi-controller
kubectl get pods -n kube-system -l app=ebs-csi-node

# Check storage classes
kubectl get storageclass
```

## Step 3: Updated Deployment Scripts

Since you have the `grafana.yaml` file, here are the corrected deployment scripts:## Step 4: Create Directory Structure (Optional)

If the script references `${HOME}/environment/grafana/grafana.yaml`, create the directory structure:

```bash
# Create directory structure
mkdir -p ${HOME}/environment/grafana

# Copy grafana.yaml to expected location
cp grafana.yaml ${HOME}/environment/grafana/grafana.yaml
```

## Step 5: Execute the Installation

Now run the deployments in order:

```bash
# 1. First install EBS CSI driver
kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=release-1.20"

# 2. Wait for driver to be ready
kubectl wait --for=condition=ready pod -l app=ebs-csi-controller -n kube-system --timeout=300s

# 3. Install Prometheus
chmod +x prometheus-deploy-fixed.sh
./prometheus-deploy-fixed.sh

# 4. Install Grafana
chmod +x grafana-deploy-corrected.sh
./grafana-deploy-corrected.sh
```

## Step 6: Verify Everything is Working

```bash
# Check all persistent volumes are bound
kubectl get pvc -A

# Check all pods are running
kubectl get pods -n prometheus
kubectl get pods -n grafana

# Get service endpoints
kubectl get svc -n prometheus
kubectl get svc -n grafana
```

## Key Points:

1. **Storage Class**: Using `gp2` as in your original scripts since the EBS CSI driver should create this automatically
2. **Grafana Configuration**: Your `grafana.yaml` already contains the Prometheus datasource configuration, so Grafana will automatically connect to Prometheus
3. **LoadBalancer**: Both services will get AWS LoadBalancer endpoints you can access directly
4. **Credentials**: Grafana admin password is set to `EKS!sAWSome` as specified

The Prometheus datasource should be automatically available in Grafana thanks to your `grafana.yaml` configuration file.