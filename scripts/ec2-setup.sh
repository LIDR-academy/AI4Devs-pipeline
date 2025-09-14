#!/bin/bash

# EC2 Setup Script for LTI Backend Pipeline
# Run this script on your EC2 instance after launching it

echo "🚀 Starting EC2 setup for LTI Backend Pipeline..."

# Update system
echo "📦 Updating system packages..."
sudo yum update -y

# Install Docker
echo "🐳 Installing Docker..."
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -a -G docker ec2-user

# Install AWS CLI v2
echo "☁️ Installing AWS CLI v2..."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf awscliv2.zip aws/

# Install curl (for health checks)
echo "🔧 Installing curl..."
sudo yum install -y curl

# Create application directory
echo "📁 Creating application directory..."
mkdir -p /home/ec2-user/lti-backend
mkdir -p /home/ec2-user/lti-backend/logs

# Create environment file template
echo "⚙️ Creating environment file template..."
cat > /home/ec2-user/lti-backend/.env << EOF
DATABASE_URL=postgresql://LTIdbUser:D1ymf8wyQEGthFR1E9xhCq@localhost:5432/LTIdb
NODE_ENV=production
PORT=3010
EOF

# Set permissions
echo "🔐 Setting permissions..."
chown -R ec2-user:ec2-user /home/ec2-user/lti-backend
chmod 755 /home/ec2-user/lti-backend

# Create systemd service for Docker (optional)
echo "🔧 Creating Docker systemd service..."
sudo systemctl daemon-reload

# Display ECR login command
echo "🔑 ECR Login Command (run this after configuring AWS credentials):"
echo "aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <YOUR_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com"

echo "✅ EC2 setup completed!"
echo ""
echo "📋 Next steps:"
echo "1. Configure AWS credentials: aws configure"
echo "2. Get your AWS Account ID: aws sts get-caller-identity"
echo "3. Update the ECR login command above with your Account ID"
echo "4. Test Docker: docker --version"
echo "5. Test AWS CLI: aws --version"
echo ""
echo "🔧 Security Group Requirements:"
echo "- Port 22 (SSH): 0.0.0.0/0"
echo "- Port 80 (HTTP): 0.0.0.0/0"
echo "- Port 3010 (Backend): 0.0.0.0/0"
echo ""
echo "🏷️ IAM Role Permissions needed:"
echo "- AmazonEC2ContainerRegistryReadOnly"
echo "- AmazonEC2ContainerRegistryPowerUser (optional, for image management)"
