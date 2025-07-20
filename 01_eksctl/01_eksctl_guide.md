Yes, you should run both scripts, and the **order matters**. Here's the correct sequence:

## 1. First: Run `create-cluster.sh`
```bash
chmod +x create-cluster.sh
./create-cluster.sh
```

This will:
- Create the EKS cluster with 3 managed nodes
- Set up the initial infrastructure
- Configure your local `kubectl` context automatically (eksctl does this)

## 2. Then: Run `configmap.sh` (if needed)
```bash
chmod +x configmap.sh
./configmap.sh
```

**However**, you might not need the configmap script immediately because:
- The IAM user/role that runs `create-cluster.sh` automatically gets admin access
- If you're running both scripts from the same EC2 instance with the same IAM credentials, you already have access

## When you DO need the configmap script:
- **Other team members** need cluster access
- **Different IAM users/roles** need to manage the cluster
- **CI/CD pipelines** from other AWS accounts need access
- **Applications** need specific permissions

## Prerequisites for your EC2 instance:
Make sure your EC2 instance has:
1. **IAM role** with EKS permissions (or AWS credentials configured)
2. **eksctl** installed
3. **kubectl** installed
4. **AWS CLI** configured

## Pro tip:
After creating the cluster, test access with:
```bash
kubectl get nodes
```

If this works, you have proper access and may not need to modify the aws-auth ConfigMap right away.

The configmap becomes essential later when you need to grant access to additional users or services beyond the cluster creator.