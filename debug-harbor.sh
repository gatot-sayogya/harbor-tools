#!/bin/bash
# Harbor Connection Debug Script
# This script tests Harbor API connectivity and authentication

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║          Harbor Connection Debug Tool                            ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

HARBOR_URL="${1:-http://192.168.72.8:30012}"
HARBOR_USER="${2:-admin}"
HARBOR_PASS="${3:-GoaHarbor2026}"

# Add http:// prefix if missing
if [[ ! "$HARBOR_URL" =~ ^https?:// ]]; then
    HARBOR_URL="http://$HARBOR_URL"
fi

echo "Configuration:"
echo "  URL:      $HARBOR_URL"
echo "  Username: $HARBOR_USER"
echo "  Password: [HIDDEN]"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test 1: Basic Connectivity"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
curl -k -w "\n  HTTP Status: %{http_code}\n  Time Total: %{time_total}s\n" "$HARBOR_URL/api/v2.0/systeminfo" --max-time 5 2>&1 || echo "  ❌ Cannot reach Harbor server"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test 2: Login API"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
LOGIN_RESPONSE=$(curl -s -k -X POST "${HARBOR_URL}/c/login" \
  -H "Content-Type: application/json" \
  -d "{\"principal\":\"$HARBOR_USER\",\"password\":\"$HARBOR_PASS\"}")

echo "Response:"
echo "$LOGIN_RESPONSE" | jq '.' 2>/dev/null || echo "  ❌ Invalid JSON response (HTML error?):"
echo "$LOGIN_RESPONSE" | head -c 200
echo ""

TOKEN=$(echo "$LOGIN_RESPONSE" | jq -r '.token // empty')
if [ "$TOKEN" != "null" ] && [ -n "$TOKEN" ] && [ "$TOKEN" != "empty" ]; then
    echo "✅ Login successful! Token: ${TOKEN:0:20}..."
else
    echo "❌ Login failed!"
    echo "Error details:"
    echo "$LOGIN_RESPONSE" | jq -r '.error // .' 2>/dev/null
    exit 1
fi
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test 3: List Projects API"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
PROJECTS_RESPONSE=$(curl -s -k -w '\n%{http_code}' -X GET "${HARBOR_URL}/api/v2.0/projects" \
  -H "Authorization: Bearer $TOKEN" \
  -G --data-urlencode "page=1" \
  --data-urlencode "page_size=10")

# Extract status and body
PROJECTS_STATUS=$(printf '%s' "$PROJECTS_RESPONSE" | tail -n1)
PROJECTS_BODY=$(printf '%s' "$PROJECTS_RESPONSE" | sed '$d')

echo "HTTP Status: $PROJECTS_STATUS"

if [ "$PROJECTS_STATUS" = "200" ]; then
    echo "✅ Projects API successful!"
    echo ""
    PROJECT_COUNT=$(echo "$PROJECTS_BODY" | jq '. | length')
    echo "Found $PROJECT_COUNT project(s):"
    echo "$PROJECTS_BODY" | jq -r '.[] | "  • \(.name) (\(.public | if . then "Public" else "Private" end))"' 2>/dev/null || echo "  (Could not parse project list)"
else
    echo "❌ Projects API failed!"
    echo "Response (first 300 chars):"
    echo "$PROJECTS_BODY" | head -c 300
fi
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test 4: List Robots API"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
ROBOTS_RESPONSE=$(curl -s -k -w '\n%{http_code}' -X GET "${HARBOR_URL}/api/v2.0/robots" \
  -H "Authorization: Bearer $TOKEN")

ROBOTS_STATUS=$(printf '%s' "$ROBOTS_RESPONSE" | tail -n1)
ROBOTS_BODY=$(printf '%s' "$ROBOTS_RESPONSE" | sed '$d')

echo "HTTP Status: $ROBOTS_STATUS"

if [ "$ROBOTS_STATUS" = "200" ]; then
    echo "✅ Robots API successful!"
    echo ""
    ROBOT_COUNT=$(echo "$ROBOTS_BODY" | jq '. | length')
    echo "Found $ROBOT_COUNT robot(s):"
    echo "$ROBOTS_BODY" | jq -r '.[] | "  • \(.name) - Expires: \(.expires_at // "Never")"' 2>/dev/null || echo "  (Could not parse robot list)"
else
    echo "❌ Robots API failed!"
    echo "Response (first 300 chars):"
    echo "$ROBOTS_BODY" | head -c 300
fi
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ "$TOKEN" != "null" ] && [ -n "$TOKEN" ] && [ "$PROJECTS_STATUS" = "200" ]; then
    echo "✅ Harbor API is working correctly!"
    echo ""
    echo "Your Harbor connection is ready to use with the main script."
    echo ""
    echo "Next steps:"
    echo "  1. Run: ./harbor-robot-manager.sh"
    echo "  2. Select option 1 (Create robot)"
    echo "  3. Follow the prompts"
else
    echo "❌ Harbor API has issues"
    echo ""
    echo "Troubleshooting:"
    echo "  • Check Harbor is running: curl -k $HARBOR_URL"
    echo "  • Verify credentials"
    echo "  • Check network connectivity"
fi
