# Harbor Robot Credentials Management Scripts

Collection of scripts to manage Harbor registry robot accounts and apply them to Kubernetes clusters.

---

## 📁 Scripts Overview

### 1. **Interactive Script** - `apply-harbor-credentials.sh`
User-friendly, interactive script with prompts.

**Features:**
- 🎯 Step-by-step prompts
- 📋 Lists all namespaces for selection
- 🔧 Multiple service account options
- ✅ Dry-run confirmation before applying
- 📊 Summary statistics

**Usage:**
```bash
./apply-harbor-credentials.sh
```

**Follow the prompts:**
1. Enter Harbor URL (default: `192.168.72.8:30012`)
2. Enter robot username (e.g., `robot$jenkins-global-robot`)
3. Enter robot token (secret input, confirmed twice)
4. Select namespaces (all, specific, or regex pattern)
5. Select service accounts to patch
6. Confirm and apply

---

### 2. **Quick Script** - `apply-harbor-credentials-quick.sh`
Fast, non-interactive script for automation/CI-CD.

**Features:**
- ⚡ Command-line arguments
- 🚀 Perfect for automation
- 🎯 Applies to default and jenkins service accounts

**Usage:**
```bash
# Apply to specific namespaces
./apply-harbor-credentials-quick.sh 'robot$jenkins-robot' 'your-token-here' 'jenkins,goapotik'

# Apply to ALL namespaces
./apply-harbor-credentials-quick.sh 'robot$jenkins-robot' 'your-token-here'

# With custom Harbor URL
HARBOR_URL="harbor.example.com" ./apply-harbor-credentials-quick.sh 'robot$jenkins-robot' 'token'
```

---

### 3. **Robot Creation** - `create-harbor-robot.sh` / `create-harbor-robot-simple.sh`
Create Harbor robot account with all-projects access via API.

**Usage:**
```bash
# 1. Edit the script
nano create-harbor-robot-simple.sh

# 2. Update credentials
# HARBOR_ADMIN_PASSWORD="your-admin-password"

# 3. Run the script
./create-harbor-robot-simple.sh

# 4. Copy the generated token!
```

---

### 4. **List Robots** - `list-harbor-robots.sh`
List all existing robot accounts in Harbor.

**Usage:**
```bash
# 1. Edit the script with admin credentials
nano list-harbor-robots.sh

# 2. Run
./list-harbor-robots.sh
```

---

## 🚀 Quick Start Guide

### **Step 1: Create Harbor Robot Account**

**Option A: Via Harbor Web UI**
1. Login to `https://192.168.72.8:30012`
2. Go to **Administration** → **Robot Accounts**
3. Click **New Robot Account**
4. Set:
   - Name: `jenkins-global-robot`
   - Scope: **All projects**
   - Permissions: `Pull` + `Push`
5. **Copy the token immediately!**

**Option B: Via API Script**
```bash
./create-harbor-robot-simple.sh
```

---

### **Step 2: Apply to Kubernetes**

**Option A: Interactive (Recommended for first-time)**
```bash
./apply-harbor-credentials.sh
```

**Option B: Quick (For automation)**
```bash
./apply-harbor-credentials-quick.sh \
  'robot$jenkins-global-robot' \
  'your-robot-token-here' \
  'jenkins,goapotik,default'
```

---

## 📋 Common Use Cases

### **Apply to All Namespaces**
```bash
./apply-harbor-credentials-quick.sh 'robot$jenkins-robot' 'token'
```

### **Apply to Specific Namespaces**
```bash
./apply-harbor-credentials-quick.sh 'robot$jenkins-robot' 'token' 'jenkins,goapotik,production'
```

### **Apply with Custom Harbor URL**
```bash
HARBOR_URL="harbor.company.com" \
./apply-harbor-credentials-quick.sh 'robot$jenkins-robot' 'token' 'jenkins'
```

### **Apply from Environment Variables**
```bash
export HARBOR_ROBOT_USERNAME="robot\$jenkins-robot"
export HARBOR_ROBOT_TOKEN="your-token"

./apply-harbor-credentials-quick.sh "$HARBOR_ROBOT_USERNAME" "$HARBOR_ROBOT_TOKEN"
```

---

## 🔍 Verification

### **Check Secret in Namespace**
```bash
kubectl get secret harbor-registry-secret -n <namespace> -o yaml
```

### **Check Service Account**
```bash
kubectl get sa jenkins -n <namespace> -o jsonpath='{.imagePullSecrets}' | jq .
```

### **Decode and View Credentials**
```bash
kubectl get secret harbor-registry-secret -n <namespace> \
  -o jsonpath='{.data.\.dockerconfigjson}' | base64 -d | jq .
```

### **Test Docker Login**
```bash
# Extract credentials
SECRET=$(kubectl get secret harbor-registry-secret -n <namespace> \
  -o jsonpath='{.data.\.dockerconfigjson}' | base64 -d)

# Extract password
PASSWORD=$(echo "$SECRET" | jq -r '.auths."192.168.72.8:30012".password')

# Login
echo "$PASSWORD" | docker login 192.168.72.8:30012 \
  -u robot\$jenkins-global-robot --password-stdin
```

---

## 🛡️ Security Best Practices

1. **Never commit robot tokens to git**
2. **Use environment variables** for sensitive data
3. **Rotate tokens regularly** (every 90 days)
4. **Use minimal permissions** (Pull + Push only, no Delete)
5. **Set expiration dates** on robot accounts
6. **Audit robot accounts** regularly with `list-harbor-robots.sh`

---

## 📊 Examples

### **Example 1: Jenkins Pipeline Integration**
```groovy
stage('Apply Harbor Credentials') {
    steps {
        sh '''
          ./apply-harbor-credentials-quick.sh \
            'robot$jenkins-robot' \
            "${HARBOR_TOKEN}" \
            "jenkins,${K8S_NAMESPACE}"
        '''
    }
}
```

### **Example 2: Multi-Environment Setup**
```bash
# Development
./apply-harbor-credentials-quick.sh 'robot$jenkins-dev' 'dev-token' 'dev,jenkins'

# Staging
./apply-harbor-credentials-quick.sh 'robot$jenkins-staging' 'staging-token' 'staging,jenkins'

# Production
./apply-harbor-credentials-quick.sh 'robot$jenkins-prod' 'prod-token' 'prod,jenkins'
```

### **Example 3: Apply to New Namespace**
```bash
# Create new namespace
kubectl create namespace my-new-app

# Apply Harbor credentials
./apply-harbor-credentials-quick.sh 'robot$jenkins-robot' 'token' 'my-new-app'
```

---

## 🐛 Troubleshooting

### **Issue: "robot$username" not working**
**Solution:** Escape the `$` sign: `'robot$jenkins-robot'` or `"robot\$jenkins-robot"`

### **Issue: Secret already exists**
**Solution:** Scripts automatically update existing secrets using `kubectl apply --dry-run=client`

### **Issue: Service account not found**
**Solution:** Scripts skip non-existent service accounts automatically

### **Issue: Permission denied**
**Solution:** Ensure you have cluster-admin or namespace admin permissions

---

## 📝 Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `HARBOR_URL` | `192.168.72.8:30012` | Harbor registry URL |
| `HARBOR_EMAIL` | `jenkins@goapotik.com` | Email for secret |
| `SECRET_NAME` | `harbor-registry-secret` | Kubernetes secret name |

---

## 📚 Additional Resources

- [Harbor Documentation](https://goharbor.io/docs/)
- [Kubernetes Secrets](https://kubernetes.io/docs/concepts/configuration/secret/)
- [Service Accounts](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/)
