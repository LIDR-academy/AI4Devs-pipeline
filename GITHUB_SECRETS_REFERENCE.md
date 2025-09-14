# 🔐 GitHub Secrets Reference

## Required Secrets for Pipeline

Add these secrets in your GitHub repository:
**Settings → Secrets and variables → Actions → New repository secret**

| Secret Name | Description | How to Get | Example |
|-------------|-------------|------------|---------|
| `AWS_ACCESS_KEY_ID` | AWS Access Key ID | AWS Console → IAM → Users → Your User → Security credentials | `AKIAIOSFODNN7EXAMPLE` |
| `AWS_SECRET_ACCESS_KEY` | AWS Secret Access Key | Same as above (create new access key if needed) | `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY` |
| `AWS_REGION` | AWS Region | Your preferred region | `us-east-1` |
| `EC2_HOST` | EC2 Public IP/DNS | EC2 Console → Instances → Your Instance → Public IPv4 address | `54.123.45.67` |
| `EC2_USERNAME` | EC2 Username | Depends on AMI: `ec2-user` (Amazon Linux) or `ubuntu` (Ubuntu) | `ec2-user` |
| `EC2_SSH_KEY` | SSH Private Key | Content of your `.pem` file | `-----BEGIN RSA PRIVATE KEY-----...` |

## Quick Setup Commands

### Get AWS Account ID
```bash
aws sts get-caller-identity --query Account --output text
```

### Get ECR Repository URI
```bash
aws ecr describe-repositories --repository-names lti-backend --region us-east-1 --query 'repositories[0].repositoryUri' --output text
```

### Test ECR Login
```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <YOUR_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com
```

## Security Best Practices

1. **Use IAM Roles** instead of access keys when possible
2. **Rotate access keys** regularly
3. **Use least privilege** principle for IAM policies
4. **Never commit** secrets to code
5. **Use different keys** for different environments

## Troubleshooting Secrets

### Check if secrets are set:
1. Go to GitHub repository
2. Settings → Secrets and variables → Actions
3. Verify all 6 secrets are listed

### Test AWS credentials:
```bash
aws sts get-caller-identity
```

### Test SSH connection:
```bash
ssh -i your-key.pem ec2-user@your-ec2-ip
```
