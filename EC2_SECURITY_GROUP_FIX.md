# 🔧 Fix EC2 Security Group for SSH Access

## 🚨 Problem
GitHub Actions cannot connect to your EC2 instance due to SSH connection timeout. This is because the Security Group doesn't allow SSH access from external sources.

## ✅ Solution: Update Security Group

### Step 1: Find Your Security Group
1. Go to **AWS Console** → **EC2** → **Instances**
2. Find your instance `i-04dd98425eda7ee4b`
3. Click on the instance
4. Look at the **Security** tab
5. Note the **Security Group** name (e.g., `launch-wizard-1`)

### Step 2: Edit Security Group Rules
1. Go to **AWS Console** → **EC2** → **Security Groups**
2. Find and click on your security group
3. Click **Edit inbound rules**
4. Click **Add rule**
5. Configure the new rule:
   - **Type**: SSH
   - **Protocol**: TCP
   - **Port range**: 22
   - **Source**: `0.0.0.0/0` (allows from anywhere)
   - **Description**: "Allow SSH from GitHub Actions"
6. Click **Save rules**

### Step 3: Verify Instance is Running
1. Go to **AWS Console** → **EC2** → **Instances**
2. Check that your instance `i-04dd98425eda7ee4b` shows **State**: `running`
3. If it's stopped, click **Instance state** → **Start instance**

### Step 4: Test Connection
After updating the Security Group, the pipeline should be able to connect. The connection test will show:
- ✅ SSH port 22 is accessible
- ✅ Basic connectivity tests

## 🔒 Security Note
For production, you should restrict the SSH access to specific IP ranges instead of `0.0.0.0/0`. For now, this allows the pipeline to work.

## 🚀 Next Steps
1. Update the Security Group as described above
2. Run the pipeline again
3. The SSH connection should now work
4. Deployment should proceed successfully
