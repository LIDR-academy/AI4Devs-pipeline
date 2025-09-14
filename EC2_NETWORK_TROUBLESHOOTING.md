# 🔧 EC2 Network Connectivity Troubleshooting

## 🚨 Problem Identified
**SSH Connection Timeout**: `dial tcp ***:22: i/o timeout`

This means GitHub Actions cannot reach your EC2 instance on port 22 at all. Since your Security Group is correctly configured, the issue is likely one of these:

## ✅ Step-by-Step Troubleshooting

### 1. Check EC2 Instance Status
1. Go to **AWS Console** → **EC2** → **Instances**
2. Find your instance `i-04dd98425eda7ee4b`
3. **Verify the instance is running**:
   - State should be `running` (green)
   - If it's `stopped`, click **Instance state** → **Start instance**

### 2. Check Public IP Address
1. In the **Instances** view, look at your instance details
2. **Check if it has a Public IPv4 address**:
   - If **Public IPv4 address** shows `-` or is empty, the instance has no public IP
   - If it shows an IP like `13.58.88.141`, note it down

### 3. Verify Public IP in GitHub Secrets
1. Go to **GitHub** → **Settings** → **Secrets and variables** → **Actions**
2. Check your `EC2_HOST` secret
3. **Make sure it matches** the Public IPv4 address from step 2
4. If they don't match, update the `EC2_HOST` secret

### 4. Check Subnet Configuration
1. In **EC2** → **Instances**, click on your instance
2. Go to the **Networking** tab
3. **Check the Subnet**:
   - If it's a **public subnet**, it should have internet access
   - If it's a **private subnet**, it won't be accessible from the internet

### 5. Check Route Table
1. Go to **VPC** → **Route Tables**
2. Find the route table for your instance's subnet
3. **Check for a route to `0.0.0.0/0`**:
   - If it exists and points to an **Internet Gateway**, the subnet is public
   - If it doesn't exist or points to a **NAT Gateway**, the subnet is private

### 6. Check Network ACLs
1. Go to **VPC** → **Network ACLs**
2. Find the Network ACL for your instance's subnet
3. **Check Inbound Rules**:
   - Should allow SSH (port 22) from `0.0.0.0/0`
   - Should allow HTTP (port 80) from `0.0.0.0/0`
   - Should allow HTTPS (port 443) from `0.0.0.0/0`

## 🔧 Common Solutions

### Solution 1: Assign Public IP (if missing)
1. **Stop the instance** (if running)
2. Go to **Actions** → **Networking** → **Manage IP addresses**
3. **Enable "Auto-assign public IP"**
4. **Start the instance**
5. **Update `EC2_HOST` secret** with the new public IP

### Solution 2: Move to Public Subnet (if in private subnet)
1. **Stop the instance**
2. Go to **Actions** → **Instance settings** → **Change subnet**
3. **Select a public subnet** (one with internet gateway route)
4. **Start the instance**
5. **Update `EC2_HOST` secret** with the new public IP

### Solution 3: Fix Network ACLs (if blocking)
1. Go to **VPC** → **Network ACLs**
2. Find your subnet's Network ACL
3. **Edit Inbound Rules**:
   - Add rule: **Type**: SSH, **Port**: 22, **Source**: 0.0.0.0/0, **Action**: Allow
   - Add rule: **Type**: HTTP, **Port**: 80, **Source**: 0.0.0.0/0, **Action**: Allow
   - Add rule: **Type**: HTTPS, **Port**: 443, **Source**: 0.0.0.0/0, **Action**: Allow

## 🚀 Quick Test
After making changes, test connectivity:
```bash
# Test from your local machine
telnet YOUR_EC2_PUBLIC_IP 22
# Should connect (you can Ctrl+C to exit)
```

## 📋 Next Steps
1. **Check the issues above** in order
2. **Make necessary changes** to fix the connectivity
3. **Update GitHub secrets** if IP address changes
4. **Run the pipeline again** to test deployment

## 🔍 Most Likely Issue
Based on the symptoms, the most likely issue is that your EC2 instance **doesn't have a public IP address** or is in a **private subnet**. Check steps 2 and 4 above first.
