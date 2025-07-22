#!/bin/bash

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
