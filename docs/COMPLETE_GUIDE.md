# Harbor Robot Account Manager

**All-in-one tool for creating Harbor robot accounts and applying them to Kubernetes clusters.**

---

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Quick Start](#quick-start)
- [Usage](#usage)
- [Examples](#examples)
- [Configuration](#configuration)
- [Troubleshooting](#troubleshooting)

---

## 🎯 Overview

This is a unified script that combines all Harbor robot account and Kubernetes secret management operations into a single tool. It supports both **interactive** and **automated** modes, making it perfect for:
- One-time setup (interactive mode)
- CI/CD pipelines (automated mode)
- Day-to-day operations
- Multi-environment management

---

## ✨ Features

### Harbor Operations
- ✅ Create robot accounts with all-projects access
- ✅ List existing robot accounts
- ✅ Configure expiration dates
- ✅ Push/Pull permissions

### Kubernetes Operations
- ✅ Apply credentials to any namespace
- ✅ Patch service accounts automatically
- ✅ Support for multiple namespaces
- ✅ Dry-run mode for testing

### Modes
- 🖥️ **Interactive Mode**: User-friendly menu system
- 🤖 **Automated Mode**: Command-line arguments for scripts
- 👀 **Dry-Run Mode**: Preview changes without applying

---

## 🚀 Quick Start

### **Installation**

```bash
# Download and make executable
chmod +x harbor-robot-manager.sh

# Run interactive mode
./harbor-robot-manager.sh
```

### **Basic Workflow**

#### Option 1: Interactive (Recommended for First Time)

```bash
./harbor-robot-manager.sh
# Select: 1. Create Harbor robot account
# Follow prompts
# Select: 3. Apply Harbor credentials to Kubernetes
```

#### Option 2: Automated (For CI/CD)

```bash
# Step 1: Create robot
./harbor-robot-manager.sh --auto --create-robot \
  --harbor-url "192.168.72.8:30012" \
  --admin-pass "your-admin-pass" \
  --robot-name "jenkins-prod" \
  --expires 90

# Step 2: Apply to Kubernetes
./harbor-robot-manager.sh --auto --apply-k8s \
  --robot-user "robot\$jenkins-prod" \
  --token "<token-from-step-1>" \
  --namespaces "jenkins,goapotik,production"
```

---

## 📖 Usage

### **Interactive Mode**

```bash
./harbor-robot-manager.sh
```

You'll see a menu:
```
╔══════════════════════════════════════════════════════════════════╗
║        Harbor Robot Account Manager - v1.0.0                     ║
║    Create & Manage Harbor Robot Accounts in Kubernetes           ║
╚══════════════════════════════════════════════════════════════════╝

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Main Menu
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Harbor Operations:
  1. Create Harbor robot account
  2. List existing robot accounts

Kubernetes Operations:
  3. Apply Harbor credentials to Kubernetes

Other:
  4. Help
  0. Exit
```

---

### **Automated Mode**

```bash
./harbor-robot-manager.sh --auto <options>
```

#### **Create Robot Account**

```bash
./harbor-robot-manager.sh --auto --create-robot \
  --harbor-url "https://192.168.72.8:30012" \
  --admin-user "admin" \
  --admin-pass "HarborAdmin123!" \
  --robot-name "jenkins-global-robot" \
  --robot-desc "Jenkins CI/CD for all projects" \
  --expires 365
```

**Output:**
```
✅ Robot created: robot$jenkins-global-robot
Secret: aBcDeFgHiJkLmNoPqRsTuVwXyZ123456789
Token saved to: .harbor_robot_token_20250220_143022
```

#### **Apply to Kubernetes**

```bash
./harbor-robot-manager.sh --auto --apply-k8s \
  --robot-user "robot\$jenkins-global-robot" \
  --token "aBcDeFgHiJkLmNoPqRsTuVwXyZ123456789" \
  --namespaces "jenkins,goapotik,default" \
  --service-accounts "default,jenkins" \
  --secret-name "harbor-registry-secret"
```

**Output:**
```
Processing namespace: jenkins... ✓ DONE (2 SA(s) patched)
Processing namespace: goapotik... ✓ DONE (2 SA(s) patched)
Processing namespace: default... ✓ DONE (2 SA(s) patched)

Success:    3 namespace(s)
Skipped:    0 namespace(s)
Failed:     0 namespace(s)
```

#### **List Robot Accounts**

```bash
./harbor-robot-manager.sh --auto --list-robots \
  --harbor-url "https://192.168.72.8:30012" \
  --admin-pass "HarborAdmin123!"
```

---

## 💡 Examples

### **Example 1: Complete Workflow (Dev Environment)**

```bash
#!/bin/bash
# setup-dev-harbor-credentials.sh

# 1. Create robot account
echo "Creating Harbor robot account for dev environment..."
RESULT=$(./harbor-robot-manager.sh --auto --create-robot \
  --harbor-url "192.168.72.8:30012" \
  --admin-pass "${HARBOR_ADMIN_PASSWORD}" \
  --robot-name "jenkins-dev" \
  --expires 90)

# Extract token
ROBOT_TOKEN=$(echo "$RESULT" | grep "Secret:" | awk '{print $2}')
ROBOT_USER="robot\$jenkins-dev"

# 2. Apply to dev namespaces
echo "Applying credentials to dev namespaces..."
./harbor-robot-manager.sh --auto --apply-k8s \
  --robot-user "$ROBOT_USER" \
  --token "$ROBOT_TOKEN" \
  --namespaces "dev,jenkins"

echo "✅ Dev environment setup complete!"
```

---

### **Example 2: Multi-Environment Setup**

```bash
#!/bin/bash
# setup-all-environments.sh

HARBOR_URL="192.168.72.8:30012"
HARBOR_ADMIN_PASS="your-admin-password"

# Dev environment
./harbor-robot-manager.sh --auto --create-robot \
  --harbor-url "$HARBOR_URL" \
  --admin-pass "$HARBOR_ADMIN_PASS" \
  --robot-name "jenkins-dev" \
  --expires 90 | grep "Secret:" | awk '{print $2}' > /tmp/dev-token

./harbor-robot-manager.sh --auto --apply-k8s \
  --robot-user "robot\$jenkins-dev" \
  --token "$(cat /tmp/dev-token)" \
  --namespaces "dev,jenkins"

# Staging environment
./harbor-robot-manager.sh --auto --create-robot \
  --harbor-url "$HARBOR_URL" \
  --admin-pass "$HARBOR_ADMIN_PASS" \
  --robot-name "jenkins-staging" \
  --expires 90 | grep "Secret:" | awk '{print $2}' > /tmp/staging-token

./harbor-robot-manager.sh --auto --apply-k8s \
  --robot-user "robot\$jenkins-staging" \
  --token "$(cat /tmp/staging-token)" \
  --namespaces "staging,jenkins"

# Production environment (with longer expiration)
./harbor-robot-manager.sh --auto --create-robot \
  --harbor-url "$HARBOR_URL" \
  --admin-pass "$HARBOR_ADMIN_PASS" \
  --robot-name "jenkins-prod" \
  --expires 180 | grep "Secret:" | awk '{print $2}' > /tmp/prod-token

./harbor-robot-manager.sh --auto --apply-k8s \
  --robot-user "robot\$jenkins-prod" \
  --token "$(cat /tmp/prod-token)" \
  --namespaces "prod,jenkins"

# Cleanup
rm -f /tmp/*-token

echo "✅ All environments configured!"
```

---

### **Example 3: Jenkins Pipeline Integration**

```groovy
// Jenkinsfile
pipeline {
    agent any

    environment {
        HARBOR_URL = '192.168.72.8:30012'
        HARBOR_ADMIN = credentials('harbor-admin-password')
    }

    stages {
        stage('Setup Harbor Credentials') {
            steps {
                script {
                    // Create robot account (first time only)
                    sh '''
                        if ! kubectl get secret harbor-registry-secret -n ${K8S_NAMESPACE} &>/dev/null; then
                            ./harbor-robot-manager.sh --auto --create-robot \
                                --harbor-url "${HARBOR_URL}" \
                                --admin-pass "${HARBOR_ADMIN}" \
                                --robot-name "jenkins-${ENVIRONMENT}" \
                                --expires 90 | grep "Secret:" | awk '{print $2}' > /tmp/robot_token
                        fi
                    '''
                }
            }
        }
    }
}
```

---

### **Example 4: Apply to All Namespaces**

```bash
# Using --all-namespaces flag
./harbor-robot-manager.sh --auto --apply-k8s \
  --robot-user "robot\$jenkins-global-robot" \
  --token "your-token-here" \
  --all-namespaces

# Or omit --namespaces (defaults to all)
./harbor-robot-manager.sh --auto --apply-k8s \
  --robot-user "robot\$jenkins-global-robot" \
  --token "your-token-here"
```

---

### **Example 5: Dry-Run (Preview Changes)**

```bash
./harbor-robot-manager.sh --auto --apply-k8s \
  --robot-user "robot\$jenkins-robot" \
  --token "your-token-here" \
  --namespaces "production" \
  --dry-run
```

Output:
```
⚠️  DRY RUN MODE - No changes will be made

Processing namespace: production... [DRY RUN]
  Would create secret: harbor-registry-secret
  Would patch service accounts: default,jenkins
```

---

### **Example 6: Regex Namespace Selection**

```bash
# Apply to all namespaces starting with "app-"
./harbor-robot-manager.sh --auto --apply-k8s \
  --robot-user "robot\$jenkins-robot" \
  --token "your-token-here" \
  --namespaces "^app-"
```

---

## ⚙️ Configuration

### **Environment Variables**

| Variable | Default | Description |
|----------|---------|-------------|
| `HARBOR_URL` | `192.168.72.8:30012` | Harbor registry URL |
| `HARBOR_ADMIN_USER` | `admin` | Harbor admin username |
| `HARBOR_ADMIN_PASSWORD` | - | Harbor admin password |
| `HARBOR_ROBOT_USERNAME` | - | Harbor robot username |
| `HARBOR_ROBOT_TOKEN` | - | Harbor robot token |
| `K8S_NAMESPACES` | - | Comma-separated namespace list |

### **Using Environment Variables**

```bash
# Set environment variables
export HARBOR_URL="harbor.company.com"
export HARBOR_ADMIN_USER="admin"
export HARBOR_ADMIN_PASSWORD="SecurePass123!"

# Now you don't need to specify these in the command
./harbor-robot-manager.sh --auto --create-robot
```

Or create a `.env` file:

```bash
# .env
HARBOR_URL="192.168.72.8:30012"
HARBOR_ADMIN_USER="admin"
HARBOR_ADMIN_PASSWORD="your-password"
```

Then source it:

```bash
source .env
./harbor-robot-manager.sh --auto --create-robot
```

---

## 🔍 Verification

### **Check if Secret Exists**

```bash
kubectl get secret harbor-registry-secret -n <namespace> -o yaml
```

### **Verify Service Account has Secret**

```bash
kubectl get sa jenkins -n <namespace> -o jsonpath='{.imagePullSecrets}' | jq .
```

Expected output:
```json
[{"name": "harbor-registry-secret"}]
```

### **Decode and View Credentials**

```bash
kubectl get secret harbor-registry-secret -n <namespace> \
  -o jsonpath='{.data.\.dockerconfigjson}' | base64 -d | jq .
```

### **Test Docker Login**

```bash
# Extract credentials
SECRET_JSON=$(kubectl get secret harbor-registry-secret -n <namespace> \
  -o jsonpath='{.data.\.dockerconfigjson}' | base64 -d)

# Login
PASSWORD=$(echo "$SECRET_JSON" | jq -r '.auths."192.168.72.8:30012".password')
echo "$PASSWORD" | docker login 192.168.72.8:30012 -u robot\$jenkins-robot --password-stdin
```

---

## 🐛 Troubleshooting

### **Issue: "Failed to login to Harbor"**

**Cause:** Incorrect credentials or Harbor URL

**Solution:**
```bash
# Test Harbor URL
curl -k https://192.168.72.8:30012/api/v2.0/systeminfo

# Verify credentials
echo '{"principal":"admin","password":"your-pass"}' | \
  curl -k -X POST https://192.168.72.8:30012/c/login \
  -H "Content-Type: application/json" -d @-
```

---

### **Issue: "Secret already exists"**

**Solution:** The script automatically updates existing secrets. No action needed.

---

### **Issue: "Service account not found"**

**Solution:** The script skips non-existent service accounts automatically. Or create them first:

```bash
kubectl create serviceaccount jenkins -n <namespace>
```

---

### **Issue: "robot$username not working"**

**Cause:** Dollar sign needs escaping in shell

**Solution:**
```bash
# Option 1: Single quotes (recommended)
'robot$jenkins-robot'

# Option 2: Escape with backslash
robot\$jenkins-robot

# Option 3: Double quotes with escape
"robot\$jenkins-robot"
```

---

### **Issue: Permission denied running script**

**Solution:**
```bash
chmod +x harbor-robot-manager.sh
```

---

### **Issue: jq command not found**

**Solution:**
```bash
# Ubuntu/Debian
sudo apt-get install jq

# CentOS/RHEL
sudo yum install jq

# macOS
brew install jq
```

---

## 📊 Command Reference

### **All Options**

```bash
--auto                  Run in automated mode
--dry-run              Preview changes without applying
--create-robot         Create a new Harbor robot account
--list-robots          List all existing robot accounts
--apply-k8s            Apply Harbor credentials to Kubernetes
--harbor-url <url>     Harbor registry URL
--admin-user <user>    Harbor admin username
--admin-pass <pass>    Harbor admin password
--robot-name <name>    Robot account name
--robot-desc <desc>    Robot account description
--robot-user <user>    Harbor robot username (for applying)
--token <token>        Harbor robot token
--expires <days>       Robot expiration in days (0 = never)
--namespaces <list>    Comma-separated namespace list
--all-namespaces       Apply to all namespaces
--service-accounts <list> Comma-separated service accounts
--secret-name <name>   Kubernetes secret name
-h, --help             Show help
-v, --version          Show version
```

---

## 🛡️ Security Best Practices

1. **Never commit tokens to git**
   - Add `.harbor_robot_token_*` to `.gitignore`

2. **Use environment variables for passwords**
   ```bash
   export HARBOR_ADMIN_PASSWORD="secure-password"
   ./harbor-robot-manager.sh --auto --create-robot
   ```

3. **Set expiration dates**
   - Don't use 0 (never expires) unless necessary
   - 90 days recommended for production

4. **Rotate tokens regularly**
   ```bash
   # Create new robot
   ./harbor-robot-manager.sh --auto --create-robot --expires 90

   # Update Kubernetes with new token
   ./harbor-robot-manager.sh --auto --apply-k8s --robot-user "robot\$new-robot" --token "new-token"

   # Delete old robot in Harbor UI
   ```

5. **Use minimal permissions**
   - Only Push + Pull (no Delete)
   - Scope to specific projects when possible

6. **Audit regularly**
   ```bash
   ./harbor-robot-manager.sh --auto --list-robots --admin-pass "your-pass"
   ```

---

## 📝 Comparison with Individual Scripts

| Feature | `harbor-robot-manager.sh` | Individual Scripts |
|---------|--------------------------|-------------------|
| **Single File** | ✅ Yes | ❌ Multiple files |
| **Interactive Mode** | ✅ Yes | ❌ No |
| **Automated Mode** | ✅ Yes | ✅ Yes (some) |
| **Create Robot** | ✅ Yes | ✅ Yes |
| **List Robots** | ✅ Yes | ✅ Yes |
| **Apply to K8s** | ✅ Yes | ✅ Yes |
| **Menu System** | ✅ Yes | ❌ No |
| **Dry-Run** | ✅ Yes | ❌ No |
| **Regex Namespaces** | ✅ Yes | ✅ Yes |
| **All-in-One** | ✅ Yes | ❌ No |

**Recommendation:** Use `harbor-robot-manager.sh` for all new deployments. Keep individual scripts only if you need specific functionality.

---

## 📚 Additional Resources

- [Harbor Official Documentation](https://goharbor.io/docs/)
- [Kubernetes Secrets Documentation](https://kubernetes.io/docs/concepts/configuration/secret/)
- [Kubernetes Service Accounts](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/)

---

## 🤝 Support

For issues or questions:
1. Check the troubleshooting section
2. Run with `--dry-run` to test
3. Use `--help` for command reference
4. Check script logs in `/tmp/harbor_robot_*`

---

**Version:** 1.0.0
**Last Updated:** 2025-02-20
**License:** MIT
