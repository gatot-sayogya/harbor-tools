#!/bin/bash
# Quick Apply - Harbor Robot Token to Kubernetes (Non-Interactive)
# Usage: ./apply-harbor-credentials-quick.sh <robot-username> <robot-token> [namespaces...]

set -e

# Configuration
HARBOR_URL="${HARBOR_URL:-192.168.72.8:30012}"
HARBOR_EMAIL="${HARBOR_EMAIL:-jenkins@goapotik.com}"
SECRET_NAME="${SECRET_NAME:-harbor-registry-secret}"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check arguments
if [ $# -lt 2 ]; then
    echo "Usage: $0 <robot-username> <robot-token> [namespace1,namespace2,...]"
    echo ""
    echo "Example:"
    echo "  $0 'robot\$jenkins-robot' 'your-token-here' 'jenkins,goapotik,default'"
    echo ""
    echo "Environment variables:"
    echo "  HARBOR_URL       Harbor registry URL (default: 192.168.72.8:30012)"
    echo "  HARBOR_EMAIL     Email address (default: jenkins@goapotik.com)"
    echo "  SECRET_NAME      Kubernetes secret name (default: harbor-registry-secret)"
    echo ""
    exit 1
fi

HARBOR_USERNAME="$1"
HARBOR_TOKEN="$2"
NAMESPACES="${3:-}"

echo -e "${GREEN}Applying Harbor credentials to Kubernetes...${NC}"
echo "  Harbor URL:      $HARBOR_URL"
echo "  Robot Username:  $HARBOR_USERNAME"
echo "  Secret Name:     $SECRET_NAME"
echo ""

# Determine namespaces
if [ -z "$NAMESPACES" ]; then
    echo -e "${YELLOW}No namespaces specified. Applying to ALL namespaces...${NC}"
    mapfile -t NAMESPACES < <(kubectl get ns -o jsonpath='{.items[*].metadata.name}')
else
    IFS=',' read -ra NAMESPACES <<< "$NAMESPACES"
    for i in "${!NAMESPACES[@]}"; do
        NAMESPACES[$i]=$(echo "${NAMESPACES[$i]}" | xargs)
    done
fi

SUCCESS=0
FAILED=0

# Apply to each namespace
for ns in "${NAMESPACES[@]}"; do
    echo -ne "  Processing namespace: ${ns}... "

    if ! kubectl get ns "$ns" &>/dev/null; then
        echo -e "${RED}NOT FOUND${NC}"
        ((FAILED++))
        continue
    fi

    # Create/update secret
    if kubectl create secret docker-registry "$SECRET_NAME" \
        --docker-server="$HARBOR_URL" \
        --docker-username="$HARBOR_USERNAME" \
        --docker-password="$HARBOR_TOKEN" \
        --docker-email="$HARBOR_EMAIL" \
        -n "$ns" --dry-run=client -o yaml | kubectl apply -n "$ns" -f - &>/dev/null; then

        # Patch default service account
        kubectl patch serviceaccount default \
            -n "$ns" \
            -p "{\"imagePullSecrets\": [{\"name\": \"$SECRET_NAME\"}]}" &>/dev/null || true

        # Patch jenkins service account if exists
        kubectl get sa jenkins -n "$ns" &>/dev/null && \
        kubectl patch serviceaccount jenkins \
            -n "$ns" \
            -p "{\"imagePullSecrets\": [{\"name\": \"$SECRET_NAME\"}]}" &>/dev/null || true

        echo -e "${GREEN}✓ DONE${NC}"
        ((SUCCESS++))
    else
        echo -e "${RED}FAILED${NC}"
        ((FAILED++))
    fi
done

echo ""
echo -e "${GREEN}Success: ${SUCCESS}${NC} | ${RED}Failed: ${FAILED}${NC}"

[ $FAILED -eq 0 ] && exit 0 || exit 1
