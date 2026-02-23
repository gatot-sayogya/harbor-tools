# Harbor Robot Account Manager - What's New in v1.1.0

## 🎉 New Features

### **1. Interactive Project Selection**
- 📋 **Auto-scan** Harbor projects during robot creation
- 🎯 **Multi-select** specific projects for robot access
- 🔢 **Multiple selection methods**:
  - Individual numbers: `1,3,5`
  - Range: `1-5`
  - All projects: `all`
  - Skip: `none` (defaults to all projects)

### **2. Custom Robot Names**
- ✅ **Required robot name input** (no more defaults)
- ✅ **Better naming** for environment-specific robots
- ✅ **Clearer identification** of robot accounts

### **3. List Harbor Projects**
- 🔍 **View all projects** in your Harbor registry
- 📊 **See project details**:
  - Public/Private visibility
  - Repository count
  - Creation date
  - Project ID

### **4. Enhanced CLI Options**
- 🚀 **New `--projects` flag** for automated project selection
- 🚀 **New `--list-projects` flag** to view all projects
- 📝 **Required `--robot-name`** in automated mode

---

## 📖 Usage Examples

### **Interactive Mode**

```bash
./harbor-robot-manager.sh

# Select: 1. Create Harbor robot account
# Follow prompts:
#  - Enter robot name: my-jenkins-robot
#  - Login to Harbor
#  - Select projects from list (e.g., 1,3,5 or all)
#  - Robot created with access to selected projects only!
```

### **Automated Mode**

```bash
# Create robot with specific project access
./harbor-robot-manager.sh --auto --create-robot \
  --harbor-url "192.168.72.8:30012" \
  --admin-pass "your-password" \
  --robot-name "jenkins-dev" \
  --projects "goapotik,myproject"

# Create robot with all projects access
./harbor-robot-manager.sh --auto --create-robot \
  --harbor-url "192.168.72.8:30012" \
  --admin-pass "your-password" \
  --robot-name "jenkins-global"

# List all projects
./harbor-robot-manager.sh --auto --list-projects \
  --harbor-url "192.168.72.8:30012" \
  --admin-pass "your-password"
```

---

## 🎯 Interactive Menu Changes

**Old Menu:**
```
Harbor Operations:
  1. Create Harbor robot account
  2. List existing robot accounts

Kubernetes Operations:
  3. Apply Harbor credentials to Kubernetes

Other:
  4. Help
  0. Exit
```

**New Menu:**
```
Harbor Operations:
  1. Create Harbor robot account
  2. List existing robot accounts
  3. List Harbor projects          ← NEW!

Kubernetes Operations:
  4. Apply Harbor credentials to Kubernetes

Other:
  5. Help
  0. Exit
```

---

## 📋 Project Selection Interface

When you choose to create a robot account, you'll see:

```
Select Harbor Projects

Found 5 project(s) in Harbor

Available Projects:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  [1] goapotik (Public)
  [2] library (Public)
  [3] production (Private)
  [4] staging (Private)
  [5] development (Public)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Selection Options:
  • Enter project numbers separated by commas (e.g., 1,3,5)
  • Enter range (e.g., 1-5)
  • Enter 'all' to select all projects
  • Enter 'none' to skip (will use all projects by default)

Select projects [all]: 1,3,5

✅ Selected 3 project(s):
  • goapotik
  • production
  • development
```

---

## 🔒 Security Benefits

1. **Principle of Least Privilege**
   - Robots only access the projects they need
   - Reduces risk of compromised robot tokens

2. **Better Audit Trail**
   - Clear project association in robot names
   - Easier to track which robot accesses what

3. **Environment Isolation**
   - Separate robots for dev/staging/prod
   - Project-specific access control

---

## 🔄 Migration from v1.0.0

### **Breaking Changes**

1. **`--robot-name` is now REQUIRED** in automated mode
   ```bash
   # Old (v1.0.0) - had default
   ./harbor-robot-manager.sh --auto --create-robot --admin-pass "pass"

   # New (v1.1.0) - required
   ./harbor-robot-manager.sh --auto --create-robot \
     --admin-pass "pass" \
     --robot-name "my-robot"
   ```

### **New Features Available**

1. **Project-specific robot creation**
2. **List Harbor projects**
3. **Interactive project selection**

### **Backward Compatibility**

- All existing flags still work
- All-projects access still works (just don't use `--projects` or select "all")
- Interactive mode is backward compatible

---

## 📝 Example Workflows

### **Workflow 1: Environment-Specific Robots**

```bash
# Development robot (dev projects only)
./harbor-robot-manager.sh --auto --create-robot \
  --admin-pass "pass" \
  --robot-name "jenkins-dev" \
  --projects "goapotik-dev,development"

# Staging robot (staging projects only)
./harbor-robot-manager.sh --auto --create-robot \
  --admin-pass "pass" \
  --robot-name "jenkins-staging" \
  --projects "goapotik-staging,staging"

# Production robot (production projects only)
./harbor-robot-manager.sh --auto --create-robot \
  --admin-pass "pass" \
  --robot-name "jenkins-prod" \
  --projects "goapotik-prod,production"
```

### **Workflow 2: Project-Specific Robots**

```bash
# Robot for specific project
./harbor-robot-manager.sh --auto --create-robot \
  --admin-pass "pass" \
  --robot-name "goapotik-deployer" \
  --projects "goapotik"

# Robot for multiple projects
./harbor-robot-manager.sh --auto --create-robot \
  --admin-pass "pass" \
  --robot-name "multi-project-deployer" \
  --projects "goapotik,myapp1,myapp2"
```

### **Workflow 3: Interactive Project Discovery**

```bash
./harbor-robot-manager.sh

# Select: 3. List Harbor Projects
# View all available projects
# Note the project names
# Go back and create robot with selected projects
```

---

## 🐛 Bug Fixes

- Fixed robot name being optional (now required)
- Improved project list display
- Better error messages for invalid selections

---

## 📚 Documentation Updates

- Updated help text with new options
- Added project selection examples
- Enhanced menu system
- Better inline documentation

---

## 🚀 Upgrading from v1.0.0

1. **Download new version**
   ```bash
   cd harbor-tools
   # Script is already updated to v1.1.0
   ```

2. **Update your scripts** to include `--robot-name`:
   ```bash
   # Add this to your automated scripts
   --robot-name "your-robot-name"
   ```

3. **Test in interactive mode first**
   ```bash
   ./harbor-robot-manager.sh
   # Try the new features!
   ```

---

## 💡 Tips

1. **Use descriptive robot names**:
   - ✅ `jenkins-goapotik-dev`
   - ✅ `deployer-staging-only`
   - ❌ `robot1`

2. **Limit project access**:
   - Only grant access to needed projects
   - Use separate robots for different environments

3. **List projects first**:
   - Use `--list-projects` to see available projects
   - Note project names before creating robots

4. **Use interactive mode for complex setups**:
   - Easier to select multiple projects
   - Visual confirmation of selections

---

**Version:** 1.1.0
**Release Date:** 2025-02-20
**Upgrades From:** 1.0.0
