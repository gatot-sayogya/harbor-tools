#!/bin/bash
# Harbor Robot Account Generator with All Projects Access

HARBOR_URL="https://192.168.72.8:30012"
HARBOR_ADMIN_USERNAME="admin"
HARBOR_ADMIN_PASSWORD="your-admin-password"

# Robot account configuration
ROBOT_NAME="jenkins-global-robot"
ROBOT_DESCRIPTION="Jenkins CI/CD - All projects access"
ROBOT_EXPIRES_DAYS=365  # Set to 0 for never expires

# Generate expiration date (optional)
if [ "$ROBOT_EXPIRES_DAYS" -gt 0 ]; then
  EXPIRY_DATE=$(date -u -d "+${ROBOT_EXPIRES_DAYS} days" +"%Y-%m-%dT%H:%M:%SZ")
else
  EXPIRY_DATE=""
fi

echo "Creating Harbor robot account: $ROBOT_NAME"
echo "Harbor URL: $HARBOR_URL"

# Get Harbor session token
echo "Logging in to Harbor..."
SESSION_TOKEN=$(curl -s -k -X POST "$HARBOR_URL/c/login" \
  -H "Content-Type: application/json" \
  -d "{\"principal\":\"$HARBOR_ADMIN_USERNAME\",\"password\":\"$HARBOR_ADMIN_PASSWORD\"}" | jq -r '.token')

if [ -z "$SESSION_TOKEN" ] || [ "$SESSION_TOKEN" == "null" ]; then
  echo "❌ Failed to login to Harbor!"
  exit 1
fi

echo "✅ Login successful"

# Create robot account with all projects access
echo "Creating robot account..."

# Harbor v2.x API format
PAYLOAD=$(cat <<EOF
{
  "name": "$ROBOT_NAME",
  "description": "$ROBOT_DESCRIPTION",
  "duration": $ROBOT_EXPIRES_DAYS,
  "level": "system",
  "permissions": [
    {
      "kind": "project",
      "namespace": "/*",
      "access": [
        {
          "action": "push",
          "resource": "repository"
        },
        {
          "action": "pull",
          "resource": "repository"
        },
        {
          "action": "read",
          "resource": "helm-chart"
        },
        {
          "action": "push",
          "resource": "helm-chart"
        }
      ]
    }
  ]
}
EOF
)

# Create the robot account
RESPONSE=$(curl -s -k -X POST "$HARBOR_URL/v2.0/robots" \
  -H "Authorization: Basic $SESSION_TOKEN" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD")

echo "Response: $RESPONSE" | jq '.'

# Extract robot credentials
ROBOT_SECRET=$(echo "$RESPONSE" | jq -r '.secret')

if [ -z "$ROBOT_SECRET" ] || [ "$ROBOT_SECRET" == "null" ]; then
  echo "❌ Failed to create robot account!"
  echo "Response: $RESPONSE"
  exit 1
fi

echo ""
echo "✅ Robot account created successfully!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Robot Name: robot$ROBOT_NAME"
echo "Robot Token: $ROBOT_SECRET"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "⚠️  IMPORTANT: Save this token now! You won't see it again!"
echo ""
echo "Kubernetes secret command:"
echo "kubectl create secret docker-registry harbor-registry-secret \\"
echo "  --docker-server=192.168.72.8:30012 \\"
echo "  --docker-username=robot\\$$ROBOT_NAME \\"
echo "  --docker-password=$ROBOT_SECRET \\"
echo "  --docker-email=jenkins@goapotik.com"
echo ""

# Save to file for safety
echo "$ROBOT_SECRET" > .harbor_robot_token
chmod 600 .harbor_robot_token
echo "Token also saved to: .harbor_robot_token"
