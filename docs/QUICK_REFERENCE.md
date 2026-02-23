# Harbor Scripts - Quick Overview

## 📦 Available Scripts

### 🌟 **RECOMMENDED: All-in-One Solution**

#### [`harbor-robot-manager.sh`](harbor-robot-manager.sh) - **MAIN SCRIPT**
**Complete unified tool - Use this for everything!**

- ✅ Create Harbor robot accounts
- ✅ Apply to Kubernetes namespaces
- ✅ List existing robots
- ✅ Interactive menu mode
- ✅ Automated CLI mode
- ✅ Dry-run support
- ✅ Environment variable support

**Quick Start:**
```bash
chmod +x harbor-robot-manager.sh
./harbor-robot-manager.sh                    # Interactive mode
./harbor-robot-manager.sh --help             # See all options
```

---

### 📚 **Individual Scripts** (Legacy)

These scripts are still available but **harbor-robot-manager.sh** includes all their functionality:

| Script | Purpose | Status |
|--------|---------|--------|
| `apply-harbor-credentials.sh` | Interactive apply to K8s | ⚠️ Use main script |
| `apply-harbor-credentials-quick.sh` | Quick automated apply | ⚠️ Use main script |
| `create-harbor-robot.sh` | Full-featured robot creation | ⚠️ Use main script |
| `create-harbor-robot-simple.sh` | Simple robot creation | ⚠️ Use main script |
| `list-harbor-robots.sh` | List existing robots | ⚠️ Use main script |

---

## 🚀 Quick Decision Guide

### **Which script should I use?**

#### **Scenario 1: First-time setup, interactive**
```bash
./harbor-robot-manager.sh
# Follow the menu prompts
```

#### **Scenario 2: Automated, one-command**
```bash
./harbor-robot-manager.sh --auto --create-robot --admin-pass "pass"
./harbor-robot-manager.sh --auto --apply-k8s --robot-user "robot\$user" --token "token"
```

#### **Scenario 3: CI/CD Pipeline**
```groovy
sh './harbor-robot-manager.sh --auto --apply-k8s --robot-user "robot$user" --token "${TOKEN}" --namespaces "${NS}"'
```

#### **Scenario 4: Preview without applying**
```bash
./harbor-robot-manager.sh --auto --apply-k8s --robot-user "robot\$user" --token "token" --dry-run
```

---

## 📖 Documentation

- **[HARBOR_ROBOT_MANAGER_README.md](HARBOR_ROBOT_MANAGER_README.md)** - Complete documentation
- **[HARBOR_CREDENTIALS_GUIDE.md](HARBOR_CREDENTIALS_GUIDE.md)** - Legacy guide (still useful)

---

## 🎯 Common Tasks

### **Task 1: Setup Jenkins with Harbor**
```bash
# One command to create robot and apply to Jenkins namespace
./harbor-robot-manager.sh --auto --create-robot \
  --harbor-url "192.168.72.8:30012" \
  --admin-pass "your-admin-pass" \
  --robot-name "jenkins-global" \
  --expires 365 | grep "Secret:" | awk '{print $2}' | \
  xargs -I {} ./harbor-robot-manager.sh --auto --apply-k8s \
    --robot-user "robot\$jenkins-global" \
    --token "{}" \
    --namespaces "jenkins"
```

### **Task 2: Update Existing Token**
```bash
# Just re-run the apply command with new token
./harbor-robot-manager.sh --auto --apply-k8s \
  --robot-user "robot\$jenkins-robot" \
  --token "new-token-here" \
  --all-namespaces
```

### **Task 3: Apply to New Namespace**
```bash
./harbor-robot-manager.sh --auto --apply-k8s \
  --robot-user "robot\$jenkins-robot" \
  --token "your-token" \
  --namespaces "my-new-namespace"
```

### **Task 4: Check Existing Robots**
```bash
./harbor-robot-manager.sh --auto --list-robots --admin-pass "admin-pass"
```

---

## 🔧 Requirements

- **bash** 4.0+
- **kubectl** - configured and working
- **curl** - for Harbor API
- **jq** - for JSON parsing
- Access to Harbor API (port 30012 or 443)
- Harbor admin credentials

---

## 📋 Command Cheat Sheet

```bash
# Create robot (automated)
./harbor-robot-manager.sh --auto --create-robot --admin-pass "pass"

# Create robot with custom settings
./harbor-robot-manager.sh --auto --create-robot \
  --admin-pass "pass" \
  --robot-name "my-robot" \
  --expires 90

# Apply to all namespaces
./harbor-robot-manager.sh --auto --apply-k8s \
  --robot-user "robot\$user" \
  --token "token" \
  --all-namespaces

# Apply to specific namespaces
./harbor-robot-manager.sh --auto --apply-k8s \
  --robot-user "robot\$user" \
  --token "token" \
  --namespaces "ns1,ns2,ns3"

# Dry run
./harbor-robot-manager.sh --auto --apply-k8s \
  --robot-user "robot\$user" \
  --token "token" \
  --dry-run

# List robots
./harbor-robot-manager.sh --auto --list-robots --admin-pass "pass"

# Interactive mode
./harbor-robot-manager.sh
```

---

## ⚡ Quick Setup Commands

### **One-Liner: Create + Apply**
```bash
# For development
./harbor-robot-manager.sh --auto --create-robot --admin-pass "pass" --robot-name "jenkins-dev" --expires 90 | grep "Secret:" | awk '{print $2}' | xargs -I {} ./harbor-robot-manager.sh --auto --apply-k8s --robot-user "robot\$jenkins-dev" --token "{}" --namespaces "dev,jenkins"

# For production
./harbor-robot-manager.sh --auto --create-robot --admin-pass "pass" --robot-name "jenkins-prod" --expires 180 | grep "Secret:" | awk '{print $2}' | xargs -I {} ./harbor-robot-manager.sh --auto --apply-k8s --robot-user "robot\$jenkins-prod" --token "{}" --namespaces "prod,jenkins"
```

---

## 🎓 Learning Path

### **Beginner**
1. Run `./harbor-robot-manager.sh` (interactive mode)
2. Follow the menu prompts
3. Read the documentation

### **Intermediate**
1. Use automated mode with specific options
2. Apply to multiple namespaces
3. Integrate into scripts

### **Advanced**
1. Use environment variables
2. Create multi-environment setup scripts
3. Integrate into CI/CD pipelines
4. Use dry-run for testing

---

## 📞 Help

```bash
./harbor-robot-manager.sh --help
```

Or see the full documentation: [HARBOR_ROBOT_MANAGER_README.md](HARBOR_ROBOT_MANAGER_README.md)

---

## ⚠️ Important Notes

1. **Never commit robot tokens** to git
2. **Use `.gitignore`** to prevent accidental commits (see `.gitignore_harbor_tokens`)
3. **Rotate tokens regularly** (every 90 days recommended)
4. **Use environment-specific robots** (dev, staging, prod)
5. **Set expiration dates** (don't use 0/never unless necessary)
6. **Test with dry-run** first before applying to production

---

**Last Updated:** 2025-02-20
**Version:** 1.0.0
