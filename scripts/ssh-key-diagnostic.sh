#!/bin/bash

echo "=== SSH Key Diagnostic Script ==="
echo "This script will help you verify your SSH key configuration"
echo ""

# Check if we have the SSH key file
if [ -f "ec2_ssh_key" ]; then
    echo "✅ SSH key file found: ec2_ssh_key"
    echo "Key file size: $(wc -c < ec2_ssh_key) bytes"
    echo "Key file permissions: $(ls -la ec2_ssh_key)"
    echo ""
    
    # Check key format
    echo "=== SSH Key Format Check ==="
    if grep -q "BEGIN.*PRIVATE KEY" ec2_ssh_key; then
        echo "✅ Key appears to be in correct format (contains 'BEGIN PRIVATE KEY')"
    else
        echo "❌ Key format issue: Missing 'BEGIN PRIVATE KEY' header"
    fi
    
    # Check if it's a valid SSH key
    if ssh-keygen -l -f ec2_ssh_key >/dev/null 2>&1; then
        echo "✅ SSH key is valid (ssh-keygen validation passed)"
        echo "Key fingerprint: $(ssh-keygen -l -f ec2_ssh_key | cut -d' ' -f2)"
    else
        echo "❌ SSH key validation failed"
    fi
    
    echo ""
    echo "=== Key Content Preview ==="
    echo "First line: $(head -1 ec2_ssh_key)"
    echo "Last line: $(tail -1 ec2_ssh_key)"
    
else
    echo "❌ SSH key file 'ec2_ssh_key' not found"
    echo "Please ensure the key file is in the current directory"
fi

echo ""
echo "=== GitHub Secrets Instructions ==="
echo "To update your GitHub secret:"
echo "1. Copy the ENTIRE content of your ec2_ssh_key file"
echo "2. Go to: https://github.com/mg22mex/AI4Devs-pipeline/settings/secrets/actions"
echo "3. Update the 'EC2_SSH_KEY' secret with the complete key content"
echo "4. Make sure to include the '-----BEGIN' and '-----END' lines"
echo ""
echo "=== EC2 Instance Check ==="
echo "Also verify that your EC2 instance is using the correct key pair:"
echo "1. Go to AWS Console > EC2 > Instances"
echo "2. Select your instance (i-04dd98425eda7ee4b)"
echo "3. Check the 'Key pair name' in the details"
echo "4. It should match the key pair you created (lti-backend-key)"
echo ""
echo "=== Test SSH Connection Locally ==="
echo "To test SSH connection from your local machine:"
echo "ssh -i ec2_ssh_key ec2-user@3.138.151.78"
echo ""
echo "If this works locally but fails in GitHub Actions, the issue is with the GitHub secret format."
