# 🚀 Complete Pipeline Setup Guide

This guide will walk you through setting up all the required AWS resources and configurations for your LTI Backend CI/CD pipeline.

## 📋 Prerequisites

- AWS Account with appropriate permissions
- GitHub repository with admin access
- Basic knowledge of AWS services

## 🏗️ Step 1: AWS ECR Repository Setup

### Option A: AWS Console (Recommended)
1. Go to [AWS ECR Console](https://console.aws.amazon.com/ecr/)
2. Click "Create repository"
3. Repository name: `lti-backend`
4. Leave other settings as default
5. Click "Create repository"
6. Note down the repository URI (you'll need this later)

### Option B: AWS CLI
```bash
# Install AWS CLI (if not already installed)
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Configure AWS credentials
aws configure

# Create ECR repository
aws ecr create-repository --repository-name lti-backend --region us-east-1
```

## 🖥️ Step 2: EC2 Instance Setup

### 2.1 Launch EC2 Instance
1. Go to [EC2 Console](https://console.aws.amazon.com/ec2/)
2. Click "Launch Instance"
3. Choose "Amazon Linux 2 AMI" or "Ubuntu Server 20.04 LTS"
4. Select instance type: `t2.micro` (free tier) or `t3.small`
5. Configure security group with these rules:
   - **SSH (22)**: 0.0.0.0/0
   - **HTTP (80)**: 0.0.0.0/0
   - **Custom TCP (3010)**: 0.0.0.0/0
6. Create or select a key pair
7. Launch the instance

### 2.2 Configure EC2 Instance
1. Connect to your EC2 instance via SSH:
   ```bash
   ssh -i your-key.pem ec2-user@your-ec2-public-ip
   ```

2. Run the setup script:
   ```bash
   # Download and run the setup script
   curl -o ec2-setup.sh https://raw.githubusercontent.com/mg22mex/AI4Devs-pipeline/pipeline-mg/scripts/ec2-setup.sh
   chmod +x ec2-setup.sh
   ./ec2-setup.sh
   ```

3. Configure AWS credentials on EC2:
   ```bash
   aws configure
   # Enter your AWS Access Key ID
   # Enter your AWS Secret Access Key
   # Enter your region (e.g., us-east-1)
   # Enter output format (json)
   ```

### 2.3 Create IAM Role (Optional but Recommended)
1. Go to [IAM Console](https://console.aws.amazon.com/iam/)
2. Create a new role for EC2
3. Attach these policies:
   - `AmazonEC2ContainerRegistryReadOnly`
   - `AmazonEC2ContainerRegistryPowerUser` (optional)
4. Attach the role to your EC2 instance

## 🔐 Step 3: GitHub Secrets Configuration

Go to your GitHub repository → Settings → Secrets and variables → Actions

Add these secrets:

| Secret Name | Description | Example Value |
|-------------|-------------|---------------|
| `AWS_ACCESS_KEY_ID` | Your AWS Access Key ID | `AKIAIOSFODNN7EXAMPLE` |
| `AWS_SECRET_ACCESS_KEY` | Your AWS Secret Access Key | `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY` |
| `AWS_REGION` | Your AWS region | `us-east-1` |
| `EC2_HOST` | Your EC2 public IP or DNS | `54.123.45.67` or `ec2-54-123-45-67.compute-1.amazonaws.com` |
| `EC2_USERNAME` | EC2 username | `ec2-user` (for Amazon Linux) or `ubuntu` (for Ubuntu) |
| `EC2_SSH_KEY` | Your EC2 SSH private key | Content of your `.pem` file |

### How to get your SSH key content:
```bash
# On your local machine
cat your-key.pem
# Copy the entire content including -----BEGIN RSA PRIVATE KEY----- and -----END RSA PRIVATE KEY-----
```

## 🧪 Step 4: Test the Pipeline

### 4.1 Create a Pull Request
1. Go to your GitHub repository
2. Click "Compare & pull request" for the `pipeline-mg` branch
3. Create the pull request

### 4.2 Test with a Sample Push
1. Make a small change to any file in the backend
2. Commit and push to the `pipeline-mg` branch
3. Check the Actions tab in GitHub to see the pipeline running

### 4.3 Monitor the Pipeline
1. Go to Actions tab in your GitHub repository
2. Click on the running workflow
3. Monitor each step:
   - ✅ Test stage should pass
   - ✅ Build and deploy stage should complete
   - ✅ Health check should pass

## 🔍 Step 5: Verification

### 5.1 Check Deployment
1. SSH into your EC2 instance
2. Check if the container is running:
   ```bash
   docker ps
   ```
3. Check application logs:
   ```bash
   docker logs lti-backend
   ```

### 5.2 Test the Application
1. Open your browser and go to: `http://your-ec2-ip:3010`
2. You should see: "Hola LTI!"

### 5.3 Health Check
```bash
# From your local machine or EC2
curl http://your-ec2-ip:3010/
```

## 🚨 Troubleshooting

### Common Issues and Solutions

#### 1. ECR Authentication Failed
```bash
# Check AWS credentials
aws sts get-caller-identity

# Test ECR login
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <YOUR_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com
```

#### 2. SSH Connection Failed
- Verify EC2_HOST in GitHub secrets
- Check security group allows SSH (port 22)
- Ensure SSH key is correctly formatted in GitHub secrets

#### 3. Health Check Failed
```bash
# Check container status
docker ps -a

# Check logs
docker logs lti-backend

# Check if port is accessible
netstat -tlnp | grep 3010
```

#### 4. Database Connection Issues
```bash
# Check if PostgreSQL is running (if using local DB)
sudo systemctl status postgresql

# Test database connection
docker exec lti-backend npx prisma db pull
```

## 📊 Expected Pipeline Flow

1. **Push to branch** → Pipeline triggers
2. **Test Stage** (5-10 minutes):
   - Setup PostgreSQL service
   - Install dependencies
   - Run tests
   - Build application
3. **Build & Deploy Stage** (10-15 minutes):
   - Build Docker image
   - Push to ECR
   - Deploy to EC2
   - Health check
4. **Success** → Application running on EC2

## 🎯 Success Criteria

- ✅ Pipeline runs without errors
- ✅ Tests pass
- ✅ Docker image builds and pushes to ECR
- ✅ Application deploys to EC2
- ✅ Health check passes
- ✅ Application responds at `http://your-ec2-ip:3010`

## 📞 Support

If you encounter any issues:
1. Check the GitHub Actions logs
2. Review the troubleshooting section above
3. Check EC2 instance logs
4. Verify all secrets are correctly configured

---

**Created by**: AI Assistant  
**Date**: $(date)  
**Pipeline Version**: 1.0.0
