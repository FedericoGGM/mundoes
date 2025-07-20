## How to Use the Cleanup Script

### 1. Make the script executable and run it:
```bash
chmod +x complete-cleanup.sh
./complete-cleanup.sh
```

### 2. What the script does:

**Kubernetes Resources:**
- Uninstalls Grafana and Prometheus via Helm
- Deletes all namespaces and persistent volumes
- Removes nginx deployment
- Cleans up EBS CSI driver
- Removes custom storage classes

**EKS Cluster:**
- Completely deletes the EKS cluster using eksctl
- Removes all node groups and associated resources
- Cleans up CloudFormation stacks

**Terraform Infrastructure:**
- Destroys all Terraform-managed resources
- Removes state files and cached data
- Cleans up EC2 instances, security groups, IAM roles

**AWS Resources Verification:**
- Checks for remaining EC2 instances
- Verifies EBS volumes are deleted
- Lists any remaining LoadBalancers
- Shows orphaned security groups

**Local Cleanup:**
- Removes SSH key files
- Cleans kubectl contexts
- Removes Helm repositories

### 3. Important Notes:

- **Irreversible**: This cleanup is permanent and cannot be undone
- **Data Loss**: All monitoring data, dashboards, and configurations will be lost
- **Time**: EKS cluster deletion can take 10-15 minutes
- **Manual Verification**: Always check AWS Console after cleanup

### 4. If the script fails:

**Manual AWS Console cleanup locations:**
- **EC2**: Instances, Security Groups, Key Pairs
- **EBS**: Volumes, Snapshots
- **Load Balancers**: Application/Network Load Balancers
- **IAM**: Roles starting with `eksctl-` or containing your project name
- **CloudFormation**: Stacks related to EKS
- **VPC**: Security groups and network interfaces

### 5. Cost Verification:

After running the cleanup, you should have minimal AWS costs. Any remaining charges would indicate resources that weren't properly deleted and need manual removal.

The script includes safety confirmations and detailed logging to help you track what's being deleted and identify any issues that require manual intervention.