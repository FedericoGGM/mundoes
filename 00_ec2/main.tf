# Terraform script for DevOps Integrator Project - Steps 1-3
# Creates EC2 instance with IAM role and user data for tool installation

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Variables
variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_pair_name" {
  description = "Name for the key pair"
  type        = string
  default     = "pin"
}

variable "project_name" {
  description = "Project name for tagging"
  type        = string
  default     = "devops-integrator"
}

# Data source for Ubuntu 22.04 AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Get default VPC
data "aws_vpc" "default" {
  default = true
}

# Get default subnet
data "aws_subnet" "default" {
  vpc_id            = data.aws_vpc.default.id
  availability_zone = "${var.aws_region}a"
  default_for_az    = true
}

# Create key pair
resource "aws_key_pair" "pin_key" {
  key_name   = var.key_pair_name
  public_key = file("${path.module}/pin.pem.pub") # You need to generate this file
  
  tags = {
    Name    = "${var.project_name}-keypair"
    Project = var.project_name
  }
}

# Security Group for EC2 instance
resource "aws_security_group" "ec2_sg" {
  name_prefix = "${var.project_name}-ec2-"
  vpc_id      = data.aws_vpc.default.id

  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access"
  }

  # HTTP access (for testing nginx)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP access"
  }

  # HTTPS access
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS access"
  }

  # Prometheus port (for port forwarding)
  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Prometheus access"
  }

  # Grafana port
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Grafana access"
  }

  # All outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = {
    Name    = "${var.project_name}-ec2-sg"
    Project = var.project_name
  }
}

# IAM role for EC2 (ec2-admin role)
resource "aws_iam_role" "ec2_admin_role" {
  name = "ec2-admin-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name    = "${var.project_name}-ec2-admin-role"
    Project = var.project_name
  }
}

# Attach policies to the IAM role
resource "aws_iam_role_policy_attachment" "ec2_admin_policy" {
  role       = aws_iam_role.ec2_admin_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Create instance profile
resource "aws_iam_instance_profile" "ec2_admin_profile" {
  name = "ec2-admin-profile"
  role = aws_iam_role.ec2_admin_role.name

  tags = {
    Name    = "${var.project_name}-ec2-admin-profile"
    Project = var.project_name
  }
}

# User data script for installing tools
locals {
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    region = var.aws_region
  }))
}

# EC2 Instance
resource "aws_instance" "devops_instance" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name              = aws_key_pair.pin_key.key_name
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  subnet_id             = data.aws_subnet.default.id
  iam_instance_profile  = aws_iam_instance_profile.ec2_admin_profile.name

  user_data = local.user_data

  # Storage configuration
  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
    
    tags = {
      Name    = "${var.project_name}-root-volume"
      Project = var.project_name
    }
  }

  tags = {
    Name    = "${var.project_name}-ec2-instance"
    Project = var.project_name
  }

  # Wait for instance to be ready
  depends_on = [
    aws_iam_role_policy_attachment.ec2_admin_policy
  ]
}

# Outputs
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.devops_instance.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.devops_instance.public_ip
}

output "instance_public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.devops_instance.public_dns
}

output "key_pair_name" {
  description = "Name of the created key pair"
  value       = aws_key_pair.pin_key.key_name
}

output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i pin.pem ubuntu@${aws_instance.devops_instance.public_ip}"
}

output "iam_role_arn" {
  description = "ARN of the created IAM role"
  value       = aws_iam_role.ec2_admin_role.arn
}