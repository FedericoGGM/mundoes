#!/bin/bash

# Exit on error
set -e

# Step 1: Get Cluster Info
CLUSTER_CONTEXT=$(kubectl config current-context)
CLUSTER_NAME=$(echo "$CLUSTER_CONTEXT" | cut -d'@' -f2 | cut -d'.' -f1)

echo "Cluster name: $CLUSTER_NAME"

OIDC_ISSUER=$(aws eks describe-cluster --name "$CLUSTER_NAME" --query 'cluster.identity.oidc.issuer' --output text)
echo "OIDC Issuer: $OIDC_ISSUER"

# Step 2: Create the IAM Policy
cat << 'EOF' > ebs-csi-policy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateSnapshot",
        "ec2:AttachVolume",
        "ec2:DetachVolume",
        "ec2:ModifyVolume",
        "ec2:DescribeAvailabilityZones",
        "ec2:DescribeInstances",
        "ec2:DescribeSnapshots",
        "ec2:DescribeVolumes",
        "ec2:DescribeVolumesModifications",
        "ec2:DescribeVolumeAttribute",
        "ec2:DescribeVolumeStatus",
        "ec2:CreateVolume",
        "ec2:DeleteVolume",
        "ec2:CreateTags",
        "ec2:DeleteSnapshot"
      ],
      "Resource": "*"
    }
  ]
}
EOF

aws iam create-policy \
    --policy-name AmazonEKS_EBS_CSI_Driver_Policy \
    --policy-document file://ebs-csi-policy.json || echo "Policy already exists."

# Step 3: Create Trust Policy and IAM Role
OIDC_ID=$(echo "$OIDC_ISSUER" | sed 's|https://||')

cat << EOF > trust-policy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::183295451532:oidc-provider/$OIDC_ID"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "$OIDC_ID:sub": "system:serviceaccount:kube-system:ebs-csi-controller-sa",
          "$OIDC_ID:aud": "sts.amazonaws.com"
        }
      }
    }
  ]
}
EOF

aws iam create-role \
    --role-name AmazonEKS_EBS_CSI_DriverRole \
    --assume-role-policy-document file://trust-policy.json || echo "Role already exists."

aws iam attach-role-policy \
    --role-name AmazonEKS_EBS_CSI_DriverRole \
    --policy-arn arn:aws:iam::183295451532:policy/AmazonEKS_EBS_CSI_Driver_Policy

# Step 4: Annotate the service account
kubectl annotate serviceaccount ebs-csi-controller-sa -n kube-system \
    eks.amazonaws.com/role-arn=arn:aws:iam::183295451532:role/AmazonEKS_EBS_CSI_DriverRole --overwrite

# Step 5: Restart EBS CSI components
kubectl rollout restart deployment ebs-csi-controller -n kube-system
kubectl rollout restart daemonset ebs-csi-node -n kube-system

# Final Step: Validate PVC provisioning
echo "PVCs in 'prometheus' namespace:"
kubectl get pvc -n prometheus

echo "Recent events in 'prometheus' namespace:"
kubectl get events -n prometheus --sort-by='.lastTimestamp' | tail -10
