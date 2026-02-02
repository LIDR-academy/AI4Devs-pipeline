#!/bin/bash
set -e

# ==============================================================================
# AWS OIDC Setup Script for GitHub Actions
# ==============================================================================
# This script automates the creation of the OIDC Provider and IAM Role required
# for secure GitHub Actions authentication.
#
# Prerequisite:
# - AWS CLI installed and configured (`aws configure`)
# - jq installed (optional, used for parsing if available)
# ==============================================================================

# --- Configuration Variables ---
GITHUB_ORG="pedrocortesark"
GITHUB_REPO="AI4Devs-pipeline"
ROLE_NAME="GitHubActions-LTI-Deploy"
REGION="us-east-1"  # Adjust if needed

echo "=========================================="
echo "Starting OIDC Setup for $GITHUB_ORG/$GITHUB_REPO"
echo "Region: $REGION"
echo "Role Name: $ROLE_NAME"
echo "=========================================="

# 1. Get AWS Account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
echo "✅ AWS Account ID: $ACCOUNT_ID"

# 2. Create OIDC Provider
# The thumbprint for token.actions.githubusercontent.com is static
THUMBPRINT="6938fd4d98bab03faadb97b34396831e3780aea1"

echo "Checking OIDC Provider..."
EXISTING_PROVIDER=$(aws iam list-open-id-connect-providers | grep "token.actions.githubusercontent.com" || true)

if [ -z "$EXISTING_PROVIDER" ]; then
    echo "Creating OIDC Provider..."
    aws iam create-open-id-connect-provider \
        --url "https://token.actions.githubusercontent.com" \
        --client-id-list "sts.amazonaws.com" \
        --thumbprint-list "$THUMBPRINT"
    echo "✅ OIDC Provider created."
else
    echo "✅ OIDC Provider already exists."
fi

# 3. Create IAM Role with Trust Policy
echo "Creating Trust Policy..."
cat > trust-policy.json <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::$ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringLike": {
                    "token.actions.githubusercontent.com:sub": "repo:$GITHUB_ORG/$GITHUB_REPO:*"
                },
                "StringEquals": {
                    "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
                }
            }
        }
    ]
}
EOF

echo "Creating Role $ROLE_NAME..."
# Check if role exists to avoid error
ROLE_EXISTS=$(aws iam get-role --role-name $ROLE_NAME 2>&1 || true)

if [[ $ROLE_EXISTS == *"NoSuchEntity"* ]]; then
    aws iam create-role \
        --role-name $ROLE_NAME \
        --assume-role-policy-document file://trust-policy.json
    echo "✅ Role created."
else
    echo "🔄 Role already exists. Updating Trust Policy..."
    aws iam update-assume-role-policy \
        --role-name $ROLE_NAME \
        --policy-document file://trust-policy.json
    echo "✅ Role Trust Policy updated."
fi

# 4. Attach Permissions (Least Privilege)
echo "Attaching Permissions..."
# Attaching ReadOnly access for demonstration/verification purposes.
# If you use 'appleboy/ssh-action', you mainly need this role for 'aws-actions/configure-aws-credentials' to succeed.
aws iam attach-role-policy \
  --role-name $ROLE_NAME \
  --policy-arn arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess || echo "Policy might already be attached."

echo "✅ Permissions attached."

# 5. Output Result
ROLE_ARN="arn:aws:iam::$ACCOUNT_ID:role/$ROLE_NAME"

echo ""
echo "=========================================="
echo "🎉 Setup Complete!"
echo "=========================================="
echo "Please configure the following Secret in your GitHub Repository:"
echo ""
echo "Name:  AWS_ROLE_ARN"
echo "Value: $ROLE_ARN"
echo ""
echo "Run this command to clean up temporary file:"
echo "rm trust-policy.json"
