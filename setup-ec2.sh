#!/bin/bash
set -e

# ==============================================================================
# AWS EC2 Provisioning Script for LTI Project
# ==============================================================================
# Creates: Security Group, Key Pair, and EC2 Instance with Node.js env.
#
# Prereqs: AWS CLI configured.
# ==============================================================================

KEY_NAME="LTI-KeyPair"
SG_NAME="LTI-SecurityGroup"
INSTANCE_TYPE="t2.micro"
REGION="us-east-1"
AMI_ID="resolve:ssm:/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"

echo "Using Region: $REGION"

# 1. Create Security Group
echo "Creating Security Group: $SG_NAME..."
SG_ID=$(aws ec2 create-security-group \
    --group-name $SG_NAME \
    --description "Security group for LTI App" \
    --query 'GroupId' --output text 2>/dev/null || \
    aws ec2 describe-security-groups --group-names $SG_NAME --query 'SecurityGroups[0].GroupId' --output text)

echo "✅ Security Group ID: $SG_ID"

# 2. Add Rules to Security Group
echo "Authorizing Ingress Rules..."
# SSH
aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp --port 22 --cidr 0.0.0.0/0 2>/dev/null || true
# Frontend (3000)
aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp --port 3000 --cidr 0.0.0.0/0 2>/dev/null || true
# Backend (3010)
aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp --port 3010 --cidr 0.0.0.0/0 2>/dev/null || true
# HTTP (80)
aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp --port 80 --cidr 0.0.0.0/0 2>/dev/null || true

# 3. Create Key Pair
if [ -f "${KEY_NAME}.pem" ]; then
    echo "ℹ️  Key Pair file ${KEY_NAME}.pem already exists locally. Skipping creation."
else
    echo "Creating Key Pair: $KEY_NAME..."
    aws ec2 create-key-pair \
        --key-name $KEY_NAME \
        --query 'KeyMaterial' \
        --output text > "${KEY_NAME}.pem"
    chmod 400 "${KEY_NAME}.pem"
    echo "✅ Key saved to ${KEY_NAME}.pem"
fi

# 4. Launch Instance with User Data
echo "Launching EC2 Instance..."
INSTANCE_ID=$(aws ec2 run-instances \
    --image-id $AMI_ID \
    --count 1 \
    --instance-type $INSTANCE_TYPE \
    --key-name $KEY_NAME \
    --security-group-ids $SG_ID \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=LTI-App-Instance}]" \
    --user-data file://<(cat <<EOF
#!/bin/bash
dnf update -y
dnf install -y git
# Install Node.js 18
dnf install -y nodejs
# Install PM2 and TypeScript globally
npm install -g pm2 typescript ts-node
# Setup App Directory
mkdir -p /home/ec2-user/app/backend
chown -R ec2-user:ec2-user /home/ec2-user/app
EOF
) \
    --query 'Instances[0].InstanceId' \
    --output text)

echo "✅ Instance Launched: $INSTANCE_ID"
echo "Waiting for instance to be running..."
aws ec2 wait instance-running --instance-ids $INSTANCE_ID

PUBLIC_IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
PUBLIC_DNS=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PublicDnsName' --output text)

echo "=========================================="
echo "🎉 Instance Ready!"
echo "=========================================="
echo "Instance ID: $INSTANCE_ID"
echo "Public IP:   $PUBLIC_IP"
echo "Public DNS:  $PUBLIC_DNS"
echo "Username:    ec2-user"
echo ""
echo "To connect:"
echo "ssh -i ${KEY_NAME}.pem ec2-user@$PUBLIC_DNS"
echo ""
echo "ACTION REQUIRED: Update GitHub Secrets"
echo "EC2_HOST:    $PUBLIC_IP"
echo "EC2_USER:    ec2-user"
echo "EC2_SSH_KEY: (Content of ${KEY_NAME}.pem)"
