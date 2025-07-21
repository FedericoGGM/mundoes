# Terraform Setup for DevOps Integrator Project

This Terraform configuration creates the infrastructure for steps 1-3 of the DevOps Integrator Project:
1. Creates an EC2 instance with Ubuntu 22.04
2. Installs all necessary DevOps tools via user data script
3. Assigns the ec2-admin IAM role

## Prerequisites

1. **AWS Account** with appropriate permissions
2. **Terraform** installed (version >= 1.0)
3. **AWS CLI** configured with credentials
4. **SSH Key Pair** generated

## Setup Instructions

### Step 1: Generate SSH Key Pair

```bash
# Generate SSH key pair
ssh-keygen -t rsa -b 4096 -f pin -N ""

# This creates two files:
# - pin (private key)
# - pin.pub (public key)
```

### Step 2: Prepare Files

Create the following directory structure:
```
00_ec2/
├── main.tf              # Main Terraform configuration
├── user_data.sh         # User data script
├── pin                  # Private key (generated above)
├── pin.pub              # Public key (generated above)
└── README.md            # This file
```

### Step 3: Initialize and Apply Terraform

```bash
# Initialize Terraform
terraform init

# Plan the deployment (optional but recommended)
terraform plan

# Apply the configuration
terraform apply
```

When prompted, type `yes` to confirm the deployment.

### Step 4: Connect to the Instance

After successful deployment, use the output SSH command:

```bash
# Use the command from terraform output
terraform output ssh_command

# Or manually:
ssh -i pin ubuntu@<INSTANCE_PUBLIC_IP>
```

## What Gets Created

### AWS Resources
- **EC2 Instance**: t2.micro Ubuntu 22.04 in us-east-1
- **Security Group**: Allows SSH, HTTP, HTTPS, and monitoring ports
- **IAM Role**: ec2-admin-role with AdministratorAccess
- **IAM Instance Profile**: Attached to the EC2 instance
- **Key Pair**: For SSH access

### Installed Tools (via User Data)
- Docker and Docker Compose
- AWS CLI v2
- kubectl (Kubernetes CLI)
- eksctl (EKS cluster management)
- Docker
- Helm (Kubernetes package manager)
- Terraform

## Verification

After connecting to the instance, verify the installation:

```bash
# Check installed tools
docker --version
aws --version
kubectl version --client
eksctl version
helm version

# Verify AWS configuration
aws sts get-caller-identity

# Check if user data completed successfully
ls -la /tmp/user-data-success
```

## Customization

### Variables
You can customize the deployment by modifying variables:

```bash
# Custom instance type
terraform apply -var="instance_type=t3.small"

# Custom region
terraform apply -var="aws_region=us-west-2"

# Custom project name
terraform apply -var="project_name=my-devops-project"
```

### Terraform Variables File
Create a `terraform.tfvars` file:

```hcl
aws_region    = "us-east-1"
instance_type = "t2.micro"
project_name  = "devops-integrator"
key_pair_name = "pin"
```

## Troubleshooting

### Common Issues

1. **Permission Denied (SSH)**
   ```bash
   chmod 400 pin
   ```

2. **User Data Script Fails**
   - Check `/var/log/user-data.log` on the instance
   - Look for error messages in `/var/log/cloud-init-output.log`

3. **AWS CLI Not Configured**
   - The instance uses IAM roles, no need for manual AWS configuration
   - Verify with: `aws sts get-caller-identity`

4. **Tools Not Found**
   - Wait for user data script to complete (can take 5-10 minutes)
   - Check if reboot completed: `uptime`

### Log Locations
- User data logs: `/var/log/user-data.log`
- Cloud-init logs: `/var/log/cloud-init-output.log`
- System logs: `/var/log/syslog`

## Cleanup

To destroy all created resources:

```bash
terraform destroy
```

Type `yes` when prompted to confirm destruction.

## Security Notes

- The IAM role has `AdministratorAccess` for lab purposes
- Security groups allow access from anywhere (0.0.0.0/0)
- In production, restrict access to specific IP ranges
- Consider using AWS Systems Manager Session Manager instead of SSH

## Next Steps

After the EC2 instance is ready, you can proceed with:
1. Creating the EKS cluster (Step 5 in the guide)
2. Deploying NGINX (Step 6)
3. Setting up monitoring with Prometheus and Grafana

The instance is now fully prepared for the remaining steps of the DevOps Integrator Project!