## What is EBS CSI Driver?

**Amazon EBS (Elastic Block Store)** is AWS's persistent block storage service that provides high-performance storage volumes for EC2 instances. It's like adding external hard drives to your servers that persist data even when instances are terminated.

## Why is EBS CSI Driver Required?

The **EBS CSI (Container Storage Interface) Driver** is required because:

1. **Persistent Storage**: Prometheus and Grafana need persistent storage to retain metrics data and dashboards across pod restarts
2. **Dynamic Provisioning**: Allows Kubernetes to automatically create EBS volumes when applications request persistent storage
3. **Storage Classes**: Enables different storage types (gp3, io1, etc.) based on performance requirements
4. **Pod Mobility**: Volumes can be detached from one node and attached to another when pods are rescheduled

Without the EBS CSI driver, your monitoring stack would lose all data whenever pods restart.

## Step-by-Step Installation Guide

### Step 1: Verify Your EKS Cluster
```bash
# Connect to your EC2 instance and verify cluster access
kubectl get nodes
kubectl get pods -A
```

### Step 2: Create IAM Service Account for EBS CSI Driver
```bash
# Create the IAM service account with required permissions
eksctl create iamserviceaccount \
  --name ebs-csi-controller-sa \
  --namespace kube-system \
  --cluster eks-mundos-e \
  --region us-east-1 \
  --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
  --approve \
  --override-existing-serviceaccounts
```

### Step 3: Install EBS CSI Driver Add-on
```bash
# Install the EBS CSI driver as an EKS add-on
eksctl create addon \
  --name aws-ebs-csi-driver \
  --cluster eks-mundos-e \
  --region us-east-1 \
  --service-account-role-arn arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):role/eksctl-eks-mundos-e-addon-iamserviceaccount-kub-Role1-* \
  --force
```

### Step 4: Verify Installation
```bash
# Check if EBS CSI driver pods are running
kubectl get pods -n kube-system -l app=ebs-csi-controller

# Check if the storage class is created
kubectl get storageclass
```

### Step 5: Create Storage Class (if needed)
Create a file called `ebs-storageclass.yaml`:
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: ebs-sc
provisioner: ebs.csi.aws.com
parameters:
  type: gp3
  fsType: ext4
  encrypted: "true"
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
```

Apply it:
```bash
kubectl apply -f ebs-storageclass.yaml
```

### Step 6: Test EBS CSI Driver (Optional)
Create a test PVC to verify everything works:
```yaml
# test-pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: test-ebs-claim
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: ebs-sc
  resources:
    requests:
      storage: 1Gi
```

```bash
kubectl apply -f test-pvc.yaml
kubectl get pvc test-ebs-claim
```

Once you see the PVC status as "Bound", your EBS CSI driver is working correctly. You can now proceed with installing Prometheus and Grafana, which will be able to create persistent volumes for their data storage needs.