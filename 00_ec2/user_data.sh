#!/bin/bash

# Update package manager
sudo apt update

# AWS CLI v2 Installation Script for Ubuntu EC2 Instance
# This script downloads and installs AWS CLI version 2

set -e  # Exit on any error

echo "Starting AWS CLI v2 installation..."

# Update package list
echo "Updating package list..."
sudo apt update

# Install required dependencies
echo "Installing required dependencies..."
sudo apt install -y curl unzip

# Create temporary directory for download
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Download AWS CLI v2
echo "Downloading AWS CLI v2..."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

# Extract the zip file
echo "Extracting AWS CLI v2..."
unzip awscliv2.zip

# Install AWS CLI v2
echo "Installing AWS CLI v2..."
sudo ./aws/install

# Clean up temporary files
echo "Cleaning up temporary files..."
cd ~
rm -rf "$TEMP_DIR"

# Verify installation
echo "Verifying installation..."
aws --version

echo "AWS CLI v2 installation completed successfully!"

# Install Git
echo "Installing Git"
sudo apt install -y git

# echo "Installing AWS CLI"
sudo apt install -y awscli

echo "Installing kubectl"
curl -o kubectl https://s3.us-west-2.amazonaws.com/amazon-eks/1.26.2/2023-03-17/bin/linux/amd64/kubectl
chmod +x ./kubectl
mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$PATH:$HOME/bin
echo 'export PATH=$PATH:$HOME/bin' >> ~/.bashrc
kubectl version --client

echo "Installing eksctl"
# Download EKS CLI https://github.com/weaveworks/eksctl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
export PATH=$PATH:/usr/local/bin
echo 'export PATH=$PATH:/usr/local/bin' >> ~/.bashrc
eksctl version

echo "Installing docker"
sudo apt install -y docker.io
sudo usermod -a -G docker $USER
# Note: newgrp docker may not work in script context, user should log out/in or run: sudo su - $USER
wget https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) 
sudo mv docker-compose-$(uname -s)-$(uname -m) /usr/local/bin/docker-compose
sudo chmod -v +x /usr/local/bin/docker-compose
sudo systemctl enable docker.service
sudo systemctl start docker.service

echo "Installing Helm"
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt update
sudo apt install -y helm

echo "Installing terraform"
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com/$(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update
sudo apt install -y terraform

echo "Installation complete!"
echo "Note: You may need to log out and log back in for Docker group changes to take effect."