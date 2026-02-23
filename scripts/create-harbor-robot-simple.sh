#!/bin/bash
# Simple Harbor Robot Account Creation via API (Works with Harbor 1.x/2.x)

HARBOR_URL="https://192.168.72.8:30012"
HARBOR_ADMIN_USERNAME="admin"
HARBOR_ADMIN_PASSWORD="your-admin-password"
ROBOT_NAME="jenkins-global-robot"

# Login and get token
echo "Logging in to Harbor..."
LOGIN_RESPONSE=$(curl -s -k -X POST "$HARBOR_URL/c/login" \
  -H "Content-Type: application/json" \
  -d "{\"principal\":\"$HARBOR_ADMIN_USERNAME\",\"password\":\"$HARBOR_ADMIN_PASSWORD\"}")

SESSION_TOKEN=$(echo "$LOGIN_RESPONSE" | jq -r '.token')

# Create robot account with all projects permissions
echo "Creating robot account with all projects access..."

ROBOT_DATA=$(cat <<EOF
{
  "name": "$ROBOT_NAME",
  "description": "Jenkins CI/CD robot with all projects access",
  "duration": -1,
  "disable": false,
  "level": "system",
  "permissions": [
    {
      "kind": "project",
      "namespace": "/*",
      "access": [
        {
          "resource": "repository",
          "action": "push"
        },
        {
          "resource": "repository",
          "action": "pull"
        },
        {
          "resource": "helm-chart",
          "action": "read"
        },
        {
          "resource": "helm-chart",
          "action": "push"
        }
      ]
    }
  ]
}
EOF
)

# Create robot
CREATE_RESPONSE=$(curl -s -k -X POST "$HARBOR_URL/v2.0/robots" \
  -H "Authorization: Basic $SESSION_TOKEN" \
  -H "Content-Type: application/json" \
  -d "$ROBOT_DATA")

echo "Create Response:"
echo "$CREATE_RESPONSE" | jq '.'

# Extract credentials
ROBOT_ID=$(echo "$CREATE_RESPONSE" | jq -r '.id')
ROBOT_SECRET=$(echo "$CREATE_RESPONSE" | jq -r '.secret')

if [ "$ROBOT_SECRET" != "null" ] && [ ! -z "$ROBOT_SECRET" ]; then
  echo ""
  echo "✅ Robot Account Created Successfully!"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Robot Username: robot$ROBOT_NAME-$ROBOT_ID"
  echo "Robot Secret:    $ROBOT_SECRET"
  echo "Robot ID:        $ROBOT_ID"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "Use these credentials in Kubernetes:"
  echo "kubectl create secret docker-registry harbor-registry-secret \\"
  echo "  --docker-server=192.168.72.8:30012 \\"
  echo "  --docker-username='robot$ROBOT_NAME-$ROBOT_ID' \\"
  echo "  --docker-password='$ROBOT_SECRET' \\"
  echo "  --docker-email='jenkins@goapotik.com'"

  # Save credentials
  cat > .harbor_robot_credentials <<CREDS
HARBOR_URL=$HARBOR_URL
HARBOR_ROBOT_USERNAME=robot$ROBOT_NAME-$ROBOT_ID
HARBOR_ROBOT_SECRET=$ROBOT_SECRET
HARBOR_ROBOT_ID=$ROBOT_ID
CREDS
  chmod 600 .harbor_robot_credentials
  echo ""
  echo "🔐 Credentials saved to: .harbor_robot_credentials"
else
  echo "❌ Failed to create robot account"
  echo "$CREATE_RESPONSE"
  exit 1
fi
