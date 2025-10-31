#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

API_BASE="https://mealtime.app.br/api"
EMAIL="mauriciobc@gmail.com"
PASSWORD="#M4ur1c10"

echo "=================================================="
echo "API Routes Test Script for Home Screen"
echo "=================================================="
echo ""

# Step 1: Login
echo -e "${YELLOW}[1] Testing Login...${NC}"
LOGIN_RESPONSE=$(curl -s -X POST "$API_BASE/auth/mobile" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$EMAIL\",\"password\":\"$PASSWORD\"}")

# Pretty print JSON
echo "$LOGIN_RESPONSE" | jq '.' || echo "$LOGIN_RESPONSE"

# Extract tokens
ACCESS_TOKEN=$(echo "$LOGIN_RESPONSE" | jq -r '.data.access_token // .access_token // empty')
REFRESH_TOKEN=$(echo "$LOGIN_RESPONSE" | jq -r '.data.refresh_token // .refresh_token // empty')

if [ -z "$ACCESS_TOKEN" ] || [ "$ACCESS_TOKEN" == "null" ]; then
  echo -e "${RED}ERROR: Could not extract access token${NC}"
  exit 1
fi

echo -e "${GREEN}✓ Login successful${NC}"
echo "Access Token: ${ACCESS_TOKEN:0:50}..."
echo ""

# Extract user ID from token (decode JWT payload)
USER_ID=$(echo "$ACCESS_TOKEN" | cut -d. -f2 | base64 -d 2>/dev/null | jq -r '.sub' 2>/dev/null)
echo "User ID: $USER_ID"
echo ""

# Step 2: Test /cats endpoint
echo -e "${YELLOW}[2] Testing /cats endpoint...${NC}"
CATS_RESPONSE=$(curl -s -X GET "$API_BASE/cats" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "X-User-ID: $USER_ID")

echo "$CATS_RESPONSE" | jq '.' || echo "$CATS_RESPONSE"
STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X GET "$API_BASE/cats" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "X-User-ID: $USER_ID")

if [ "$STATUS_CODE" == "200" ]; then
  echo -e "${GREEN}✓ /cats returned 200${NC}"
else
  echo -e "${RED}✗ /cats returned $STATUS_CODE${NC}"
fi
echo ""

# Step 3: Test /households endpoint
echo -e "${YELLOW}[3] Testing /households endpoint...${NC}"
HOUSEHOLDS_RESPONSE=$(curl -s -X GET "$API_BASE/households" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "X-User-ID: $USER_ID")

echo "$HOUSEHOLDS_RESPONSE" | jq '.' || echo "$HOUSEHOLDS_RESPONSE"
STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X GET "$API_BASE/households" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "X-User-ID: $USER_ID")

if [ "$STATUS_CODE" == "200" ]; then
  echo -e "${GREEN}✓ /households returned 200${NC}"
else
  echo -e "${RED}✗ /households returned $STATUS_CODE${NC}"
fi
echo ""

# Step 4: Test /schedules endpoint
echo -e "${YELLOW}[4] Testing /schedules endpoint...${NC}"
SCHEDULES_RESPONSE=$(curl -s -X GET "$API_BASE/schedules" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "X-User-ID: $USER_ID")

echo "$SCHEDULES_RESPONSE" | jq '.' || echo "$SCHEDULES_RESPONSE"
STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X GET "$API_BASE/schedules" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "X-User-ID: $USER_ID")

if [ "$STATUS_CODE" == "200" ]; then
  echo -e "${GREEN}✓ /schedules returned 200${NC}"
else
  echo -e "${RED}✗ /schedules returned $STATUS_CODE${NC}"
fi
echo ""

# Step 5: Extract household_id and test /cats?household_id=xxx
if [ ! -z "$HOUSEHOLDS_RESPONSE" ]; then
  HOUSEHOLD_ID=$(echo "$HOUSEHOLDS_RESPONSE" | jq -r '.data[0].id // empty' 2>/dev/null)
  
  if [ ! -z "$HOUSEHOLD_ID" ] && [ "$HOUSEHOLD_ID" != "null" ]; then
    echo -e "${YELLOW}[5] Testing /cats?household_id=$HOUSEHOLD_ID...${NC}"
    CATS_BY_HOME_RESPONSE=$(curl -s -X GET "$API_BASE/cats?household_id=$HOUSEHOLD_ID" \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $ACCESS_TOKEN" \
      -H "X-User-ID: $USER_ID")
    
    echo "$CATS_BY_HOME_RESPONSE" | jq '.' || echo "$CATS_BY_HOME_RESPONSE"
    echo ""
  fi
fi

echo "=================================================="
echo "Summary"
echo "=================================================="
echo "Login: ${GREEN}✓${NC}"
echo "Access Token: ${ACCESS_TOKEN:0:30}..."
echo "User ID: $USER_ID"
echo ""

# Count cats
CAT_COUNT=$(echo "$CATS_RESPONSE" | jq '.data | length' 2>/dev/null || echo "0")
echo "Cats count: $CAT_COUNT"

# Count households
HOUSEHOLD_COUNT=$(echo "$HOUSEHOLDS_RESPONSE" | jq '.data | length' 2>/dev/null || echo "0")
echo "Households count: $HOUSEHOLD_COUNT"

echo ""
echo "=================================================="
echo "Done!"
echo "=================================================="

