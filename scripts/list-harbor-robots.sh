#!/bin/bash
# List all Harbor robot accounts

HARBOR_URL="https://192.168.72.8:30012"
HARBOR_ADMIN_USERNAME="admin"
HARBOR_ADMIN_PASSWORD="your-admin-password"

# Login
echo "Logging in to Harbor..."
SESSION_TOKEN=$(curl -s -k -X POST "$HARBOR_URL/c/login" \
  -H "Content-Type: application/json" \
  -d "{\"principal\":\"$HARBOR_ADMIN_USERNAME\",\"password\":\"$HARBOR_ADMIN_PASSWORD\"}" | jq -r '.token')

# List all robots
echo ""
echo "All Robot Accounts in Harbor:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

curl -s -k -X GET "$HARBOR_URL/v2.0/robots" \
  -H "Authorization: Basic $SESSION_TOKEN" | jq -r '.[] | "
Robot ID: \(.id)
Name: \(.name)
Description: \(.description // "N/A")
Expires: \(.expires_at // "Never")
Level: \(.level // "N/A")
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"'

echo ""
echo "⚠️  Note: Secrets are only shown during creation. They cannot be retrieved later!"
