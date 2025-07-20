#!/bin/bash

echo "Verifying installation and versions..."

# Function to check command existence and version
check_command() {
    local name=$1
    local cmd=$2
    local version_flag=${3:---version}
    local expected_keyword=$4

    echo -n "Checking $name... "

    if ! command -v $cmd &> /dev/null; then
        echo "❌ Not found"
        return
    fi

    version_output=$($cmd $version_flag 2>&1)

    if [[ -n "$expected_keyword" && "$version_output" != *"$expected_keyword"* ]]; then
        echo "⚠️ Found but unexpected version or output:"
        echo "$version_output"
    else
        echo "✅ Found"
        echo "    Version: $version_output"
    fi
}

check_command "AWS CLI" "aws" "--version" "aws-cli"
check_command "kubectl" "kubectl" "version --client --short" "Client Version"
check_command "eksctl" "eksctl" "version" "eksctl"
check_command "Docker" "docker" "--version" "Docker version"
check_command "Docker Compose" "docker-compose" "--version" "Docker Compose"
check_command "Helm" "helm" "version --short" "v"
check_command "Terraform" "terraform" "version" "Terraform v"

echo "Verification complete!"
