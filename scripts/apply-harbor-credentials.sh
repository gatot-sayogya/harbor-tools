#!/bin/bash
# Harbor Robot Token to Kubernetes Secret - Interactive Script
# This script applies Harbor credentials to Kubernetes namespaces and service accounts

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Banner
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Harbor Robot Token - Kubernetes Secret Installer          ║${NC}"
echo -e "${BLUE}║  Apply Harbor credentials to namespaces & service accounts ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Prompt for Harbor registry URL
read -p "$(echo -e ${GREEN}Enter Harbor registry URL [default: 192.168.72.8:30012]: ${NC})" HARBOR_URL
HARBOR_URL=${HARBOR_URL:-"192.168.72.8:30012"}

# Prompt for robot username
read -p "$(echo -e ${GREEN}Enter Harbor robot username (e.g., robot\$jenkins-global-robot): ${NC})" HARBOR_USERNAME

# Prompt for robot token/secret (silent input)
read -s -p "$(echo -e ${GREEN}Enter Harbor robot token/secret: ${NC})" HARBOR_TOKEN
echo ""
read -s -p "$(echo -e ${GREEN}Confirm Harbor robot token/secret: ${NC})" HARBOR_TOKEN_CONFIRM
echo ""

# Validate token match
if [ "$HARBOR_TOKEN" != "$HARBOR_TOKEN_CONFIRM" ]; then
    echo -e "${RED}❌ Error: Tokens do not match!${NC}"
    exit 1
fi

# Prompt for email
read -p "$(echo -e ${GREEN}Enter email address [default: jenkins@goapotik.com]: ${NC})" HARBOR_EMAIL
HARBOR_EMAIL=${HARBOR_EMAIL:-"jenkins@goapotik.com"}

# Secret name
read -p "$(echo -e ${GREEN}Enter Kubernetes secret name [default: harbor-registry-secret]: ${NC})" SECRET_NAME
SECRET_NAME=${SECRET_NAME:-"harbor-registry-secret"}

echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Available Kubernetes Namespaces:${NC}"
echo ""

# List all namespaces
kubectl get ns -o custom-columns="NAME:.metadata.name" | tail -n +2
echo ""

# Prompt for namespaces
echo -e "${GREEN}Select target namespaces:${NC}"
echo -e "  ${YELLOW}Options:${NC}"
echo -e "    1. All namespaces"
echo -e "    2. Specific namespaces (comma-separated)"
echo -e "    3. Specific namespaces with regex pattern"
echo ""
read -p "$(echo -e ${GREEN}Enter your choice [1-3]: ${NC})" NAMESPACE_CHOICE

NAMESPACES=()

case $NAMESPACE_CHOICE in
    1)
        echo -e "${BLUE}Selected: All namespaces${NC}"
        mapfile -t NAMESPACES < <(kubectl get ns -o jsonpath='{.items[*].metadata.name}')
        ;;
    2)
        read -p "$(echo -e ${GREEN}Enter namespace names (comma-separated, e.g., jenkins,goapotik,default): ${NC})" NAMESPACE_INPUT
        IFS=',' read -ra NAMESPACES <<< "$NAMESPACE_INPUT"
        for i in "${!NAMESPACES[@]}"; do
            NAMESPACES[$i]=$(echo "${NAMESPACES[$i]}" | xargs) # trim whitespace
        done
        ;;
    3)
        read -p "$(echo -e ${GREEN}Enter regex pattern (e.g., ^jenkins|^goapotik): ${NC})" REGEX_PATTERN
        mapfile -t NAMESPACES < <(kubectl get ns -o jsonpath='{.items[*].metadata.name}' | tr ' ' '\n' | grep -E "$REGEX_PATTERN")
        ;;
    *)
        echo -e "${RED}❌ Invalid choice!${NC}"
        exit 1
        ;;
esac

if [ ${#NAMESPACES[@]} -eq 0 ]; then
    echo -e "${RED}❌ No namespaces found!${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}Target namespaces (${#NAMESPACES[@]}):${NC} ${NAMESPACES[*]}"
echo ""

# Service account options
echo -e "${GREEN}Select service accounts to patch:${NC}"
echo -e "  ${YELLOW}Options:${NC}"
echo -e "    1. default service account only"
echo -e "    2. jenkins service account only"
echo -e "    3. Both default and jenkins"
echo -e "    4. All service accounts in namespace"
echo -e "    5. Custom service account names"
echo ""
read -p "$(echo -e ${GREEN}Enter your choice [1-5]: ${NC})" SA_CHOICE

SERVICE_ACCOUNTS=()

case $SA_CHOICE in
    1)
        SERVICE_ACCOUNTS=("default")
        ;;
    2)
        SERVICE_ACCOUNTS=("jenkins")
        ;;
    3)
        SERVICE_ACCOUNTS=("default" "jenkins")
        ;;
    4)
        SERVICE_ACCOUNTS=("*")  # Special marker for all
        ;;
    5)
        read -p "$(echo -e ${GREEN}Enter service account names (comma-separated): ${NC})" SA_INPUT
        IFS=',' read -ra SERVICE_ACCOUNTS <<< "$SA_INPUT"
        for i in "${!SERVICE_ACCOUNTS[@]}"; do
            SERVICE_ACCOUNTS[$i]=$(echo "${SERVICE_ACCOUNTS[$i]}" | xargs)
        done
        ;;
    *)
        echo -e "${RED}❌ Invalid choice!${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${BLUE}Service accounts to patch:${NC} ${SERVICE_ACCOUNTS[*]}"
echo ""

# Confirmation
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Summary:${NC}"
echo -e "  Harbor URL:         ${HARBOR_URL}"
echo -e "  Harbor Username:    ${HARBOR_USERNAME}"
echo -e "  Secret Name:        ${SECRET_NAME}"
echo -e "  Namespaces:         ${#NAMESPACES[@]} namespace(s)"
echo -e "  Service Accounts:   ${SERVICE_ACCOUNTS[*]}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

read -p "$(echo -e ${GREEN}Proceed with applying credentials? [y/N]: ${NC})" CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}❌ Cancelled by user${NC}"
    exit 0
fi

echo ""
echo -e "${GREEN}🚀 Starting deployment...${NC}"
echo ""

# Counter for stats
SUCCESS_COUNT=0
SKIP_COUNT=0
ERROR_COUNT=0

# Process each namespace
for ns in "${NAMESPACES[@]}"; do
    echo -e "${BLUE}Processing namespace: ${ns}${NC}"

    # Check if namespace exists
    if ! kubectl get ns "$ns" &>/dev/null; then
        echo -e "${RED}  ⚠️  Namespace '${ns}' does not exist. Skipping...${NC}"
        ((SKIP_COUNT++))
        continue
    fi

    # Create/Update secret
    echo -e "  📝 Creating/updating secret '${SECRET_NAME}'..."
    if kubectl create secret docker-registry "$SECRET_NAME" \
        --docker-server="$HARBOR_URL" \
        --docker-username="$HARBOR_USERNAME" \
        --docker-password="$HARBOR_TOKEN" \
        --docker-email="$HARBOR_EMAIL" \
        -n "$ns" --dry-run=client -o yaml | kubectl apply -n "$ns" -f - &>/dev/null; then
        echo -e "    ${GREEN}✅ Secret created/updated${NC}"
    else
        echo -e "    ${RED}❌ Failed to create secret${NC}"
        ((ERROR_COUNT++))
        continue
    fi

    # Determine which service accounts to patch
    if [ "${SERVICE_ACCOUNTS[0]}" == "*" ]; then
        # Get all service accounts in namespace
        mapfile -t SA_LIST < <(kubectl get sa -n "$ns" -o jsonpath='{.items[*].metadata.name}')
    else
        SA_LIST=("${SERVICE_ACCOUNTS[@]}")
    fi

    # Patch service accounts
    for sa in "${SA_LIST[@]}"; do
        # Check if service account exists
        if ! kubectl get sa "$sa" -n "$ns" &>/dev/null; then
            echo -e "    ${YELLOW}⚠️  Service account '${sa}' not found. Skipping...${NC}"
            continue
        fi

        echo -e "  🔐 Patching service account '${sa}'..."

        # Check if secret already exists in imagePullSecrets
        EXISTING=$(kubectl get sa "$sa" -n "$ns" -o jsonpath='{.imagePullSecrets[*].name}' | grep -c "$SECRET_NAME" || true)

        if [ "$EXISTING" -gt 0 ]; then
            echo -e "    ${YELLOW}⏭️  Secret already exists in service account${NC}"
        else
            if kubectl patch serviceaccount "$sa" \
                -n "$ns" \
                -p "{\"imagePullSecrets\": [{\"name\": \"$SECRET_NAME\"}]}" &>/dev/null; then
                echo -e "    ${GREEN}✅ Service account patched${NC}"
            else
                echo -e "    ${RED}❌ Failed to patch service account${NC}"
                ((ERROR_COUNT++))
                continue
            fi
        fi
    done

    ((SUCCESS_COUNT++))
    echo ""
done

# Final summary
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Deployment Summary:${NC}"
echo -e "  ${GREEN}✅ Successful:  ${SUCCESS_COUNT} namespace(s)${NC}"
echo -e "  ${YELLOW}⏭️  Skipped:     ${SKIP_COUNT} namespace(s)${NC}"
echo -e "  ${RED}❌ Errors:      ${ERROR_COUNT} namespace(s)${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Verification
if [ $SUCCESS_COUNT -gt 0 ]; then
    echo -e "${GREEN}Verification:${NC}"
    echo -e "Run these commands to verify the setup:"
    echo ""
    echo -e "  # Check secret in a namespace:"
    echo -e "  kubectl get secret ${SECRET_NAME} -n <namespace> -o yaml"
    echo ""
    echo -e "  # Check service account imagePullSecrets:"
    echo -e "  kubectl get sa <service-account> -n <namespace> -o jsonpath='{.imagePullSecrets}'"
    echo ""
    echo -e "  # Test Docker login with the credentials:"
    echo -e "  kubectl get secret ${SECRET_NAME} -n <namespace> -o jsonpath='{.data.\.dockerconfigjson}' | base64 -d"
    echo ""
fi

if [ $ERROR_COUNT -eq 0 ]; then
    echo -e "${GREEN}🎉 All operations completed successfully!${NC}"
    exit 0
else
    echo -e "${RED}⚠️  Some operations failed. Please review the errors above.${NC}"
    exit 1
fi
