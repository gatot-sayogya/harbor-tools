# Harbor Robot Manager Tools

**All-in-one toolkit for managing Harbor robot accounts and Kubernetes credentials.**

---

## 🚀 Quick Start

```bash
cd harbor-tools

# Interactive mode (recommended for first-time users)
./harbor-robot-manager.sh

# Automated mode (for scripts/CI-CD)
./harbor-robot-manager.sh --auto --create-robot --admin-pass "your-password"
./harbor-robot-manager.sh --auto --apply-k8s --robot-user "robot\$jenkins" --token "your-token"
```

---

## 📁 Directory Structure

```
harbor-tools/
├── README.md                               ← This file (start here!)
│
├── harbor-robot-manager.sh                ⭐ MAIN SCRIPT - Use this for everything
│   ├── Create Harbor robot accounts
│   ├── Apply credentials to Kubernetes
│   ├── List existing robots
│   ├── Interactive mode
│   └── Automated mode
│
├── docs/                                   ← Documentation
│   ├── COMPLETE_GUIDE.md                   ← Full documentation (400+ lines)
│   ├── QUICK_REFERENCE.md                  ← Cheat sheet & examples
│   └── ORIGINAL_GUIDE.md                   ← Original detailed guide
│
├── scripts/                                ← Legacy individual scripts
│   ├── apply-harbor-credentials.sh         ← Interactive apply to K8s
│   ├── apply-harbor-credentials-quick.sh   ← Quick automated apply
│   ├── create-harbor-robot.sh              ← Full-featured robot creation
│   ├── create-harbor-robot-simple.sh       ← Simple robot creation
│   └── list-harbor-robots.sh               ← List existing robots
│
└── .gitignore                              ← Security - prevents committing tokens
```

---

## 📚 Documentation

| Document | Description |
|----------|-------------|
| **[README.md](README.md)** | This file - Quick start guide |
| **[COMPLETE_GUIDE.md](docs/COMPLETE_GUIDE.md)** | Complete documentation with all features |
| **[QUICK_REFERENCE.md](docs/QUICK_REFERENCE.md)** | Command cheat sheet & examples |
| **[ORIGINAL_GUIDE.md](docs/ORIGINAL_GUIDE.md)** | Original detailed guide |

---

## 🎯 Common Use Cases

### **Use Case 1: First-Time Setup**
```bash
./harbor-robot-manager.sh
# Follow the interactive menu
```

### **Use Case 2: Create Robot & Apply to K8s**
```bash
# Create robot
./harbor-robot-manager.sh --auto --create-robot \
  --harbor-url "192.168.72.8:30012" \
  --admin-pass "your-admin-password" \
  --robot-name "jenkins-global" \
  --expires 365

# Apply to Kubernetes (use the token from above)
./harbor-robot-manager.sh --auto --apply-k8s \
  --robot-user "robot\$jenkins-global" \
  --token "<token-from-above>" \
  --namespaces "jenkins,goapotik,default"
```

### **Use Case 3: One-Liner (Create + Apply)**
```bash
./harbor-robot-manager.sh --auto --create-robot --admin-pass "pass" --robot-name "jenkins-prod" --expires 180 | grep "Secret:" | awk '{print $2}' | xargs -I {} ./harbor-robot-manager.sh --auto --apply-k8s --robot-user "robot\$jenkins-prod" --token "{}" --namespaces "prod,jenkins"
```

### **Use Case 4: Update Existing Token**
```bash
./harbor-robot-manager.sh --auto --apply-k8s \
  --robot-user "robot\$jenkins-robot" \
  --token "new-token-here" \
  --all-namespaces
```

### **Use Case 5: Dry-Run (Preview Changes)**
```bash
./harbor-robot-manager.sh --auto --apply-k8s \
  --robot-user "robot\$jenkins-robot" \
  --token "your-token" \
  --namespaces "production" \
  --dry-run
```

### **Use Case 6: List All Robots**
```bash
./harbor-robot-manager.sh --auto --list-robots --admin-pass "your-admin-password"
```

---

## ⚡ Quick Command Reference

```bash
# Create robot account
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

# Apply with custom service accounts
./harbor-robot-manager.sh --auto --apply-k8s \
  --robot-user "robot\$user" \
  --token "token" \
  --namespaces "jenkins" \
  --service-accounts "default,jenkins,deployer"

# Dry run (test without applying)
./harbor-robot-manager.sh --auto --apply-k8s \
  --robot-user "robot\$user" \
  --token "token" \
  --dry-run

# List robots
./harbor-robot-manager.sh --auto --list-robots --admin-pass "pass"

# Interactive mode
./harbor-robot-manager.sh

# Help
./harbor-robot-manager.sh --help
```

---

## 🔧 Requirements

- **bash** 4.0+
- **kubectl** - configured and working
- **curl** - for Harbor API
- **jq** - for JSON parsing
- Access to Harbor API (port 30012 or 443)
- Harbor admin credentials (for creating robots)

---

## 📖 Which Script Should I Use?

### **RECOMMENDED: `harbor-robot-manager.sh`**
- ✅ All features in one script
- ✅ Interactive + automated modes
- ✅ Best user experience
- ✅ Actively maintained

### **Legacy Scripts** (in `scripts/` folder)
Use these only if you need specific functionality:
- `apply-harbor-credentials.sh` - Interactive apply only
- `apply-harbor-credentials-quick.sh` - Quick automated apply
- `create-harbor-robot.sh` - Robot creation via API
- `create-harbor-robot-simple.sh` - Simple robot creation
- `list-harbor-robots.sh` - List existing robots

**Note:** The main `harbor-robot-manager.sh` includes all functionality from these scripts.

---

## 🎓 Learning Path

### **Beginner**
1. Read this README
2. Run `./harbor-robot-manager.sh` (interactive mode)
3. Follow menu prompts
4. Check [QUICK_REFERENCE.md](docs/QUICK_REFERENCE.md)

### **Intermediate**
1. Use automated mode
2. Read [COMPLETE_GUIDE.md](docs/COMPLETE_GUIDE.md)
3. Apply to multiple namespaces
4. Integrate into scripts

### **Advanced**
1. Use environment variables
2. Create multi-environment setup
3. Integrate into CI/CD pipelines
4. Use dry-run for testing

---

## 🛡️ Security Best Practices

1. ✅ **Never commit robot tokens** to git
2. ✅ **Use `.gitignore`** (included in this folder)
3. ✅ **Rotate tokens regularly** (every 90 days)
4. ✅ **Use environment-specific robots** (dev/staging/prod)
5. ✅ **Set expiration dates** (avoid 0/never)
6. ✅ **Test with dry-run** before production

---

## 🔍 Verification

### **Check if secret exists**
```bash
kubectl get secret harbor-registry-secret -n <namespace> -o yaml
```

### **Verify service account has secret**
```bash
kubectl get sa jenkins -n <namespace> -o jsonpath='{.imagePullSecrets}'
```

### **Decode and view credentials**
```bash
kubectl get secret harbor-registry-secret -n <namespace> \
  -o jsonpath='{.data.\.dockerconfigjson}' | base64 -d | jq .
```

### **Test Docker login**
```bash
PASSWORD=$(kubectl get secret harbor-registry-secret -n <namespace> \
  -o jsonpath='{.data.\.dockerconfigjson}' | base64 -d | jq -r '.auths."192.168.72.8:30012".password')
echo "$PASSWORD" | docker login 192.168.72.8:30012 -u robot\$jenkins-robot --password-stdin
```

---

## 🐛 Troubleshooting

| Issue | Solution |
|-------|----------|
| "Failed to login to Harbor" | Check Harbor URL and credentials |
| "Secret already exists" | Script auto-updates, no action needed |
| "Service account not found" | Script skips non-existent SAs automatically |
| "robot\$username not working" | Use single quotes: `'robot$jenkins-robot'` or escape: `robot\$jenkins-robot` |
| "Permission denied" | Run `chmod +x harbor-robot-manager.sh` |
| "jq: command not found" | Install jq: `apt-get install jq` or `brew install jq` |

For detailed troubleshooting, see [COMPLETE_GUIDE.md](docs/COMPLETE_GUIDE.md)

---

## 📞 Help

```bash
# Show help
./harbor-robot-manager.sh --help

# Interactive mode
./harbor-robot-manager.sh
```

Or see the documentation:
- **[COMPLETE_GUIDE.md](docs/COMPLETE_GUIDE.md)** - Full documentation
- **[QUICK_REFERENCE.md](docs/QUICK_REFERENCE.md)** - Command reference
- **[ORIGINAL_GUIDE.md](docs/ORIGINAL_GUIDE.md)** - Original guide

---

## 📦 What's Included

- ✅ Main unified script (`harbor-robot-manager.sh`)
- ✅ Interactive menu system
- ✅ Automated CLI mode
- ✅ Complete documentation (3 guides)
- ✅ Legacy scripts (backward compatibility)
- ✅ Security (.gitignore for tokens)
- ✅ Examples and use cases
- ✅ Troubleshooting guide

---

## 🎯 Key Features

### **Harbor Operations**
- ✅ Create robot accounts with all-projects access
- ✅ List existing robot accounts
- ✅ Configure expiration dates
- ✅ Push/Pull permissions

### **Kubernetes Operations**
- ✅ Apply credentials to any namespace
- ✅ Patch service accounts automatically
- ✅ Support for multiple namespaces
- ✅ Dry-run mode for testing

### **Modes**
- 🖥️ **Interactive Mode**: User-friendly menu system
- 🤖 **Automated Mode**: Command-line arguments for scripts
- 👀 **Dry-Run Mode**: Preview changes without applying

---

## 📝 Version

**Version:** 1.0.0
**Last Updated:** 2025-02-20
**License:** MIT

---

## 🤝 Contributing

Suggestions and improvements welcome! Key areas:
- Additional Harbor API features
- More Kubernetes integrations
- Enhanced error handling
- Additional examples

---

**Ready to get started? Run `./harbor-robot-manager.sh` and follow the prompts!** 🚀
