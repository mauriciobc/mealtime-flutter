#!/bin/bash

# Get token from login
TOKEN=$(curl -s -X POST "https://mealtime.app.br/api/auth/mobile" \
  -H "Content-Type: application/json" \
  -d '{"email":"mauriciobc@gmail.com","password":"#M4ur1c10"}' | \
  jq -r '.access_token // .data.access_token')

echo "Token: ${TOKEN:0:50}..."
echo ""

# Test different Authorization header formats
echo "Testing different Authorization formats:"
echo ""

echo "[1] Bearer TOKEN (current format)"
curl -s -X GET "https://mealtime.app.br/api/cats" \
  -H "Authorization: Bearer $TOKEN" | jq .
echo ""

echo "[2] Just TOKEN"
curl -s -X GET "https://mealtime.app.br/api/cats" \
  -H "Authorization: $TOKEN" | jq .
echo ""

echo "[3] With X-User-ID header"
USER_ID=$(echo "$TOKEN" | cut -d. -f2 | base64 -d 2>/dev/null | jq -r '.sub')
curl -s -X GET "https://mealtime.app.br/api/cats" \
  -H "Authorization: Bearer $TOKEN" \
  -H "X-User-ID: $USER_ID" | jq .
echo ""

echo "[4] Full headers from login response"
curl -s -X GET "https://mealtime.app.br/api/cats" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -H "X-User-ID: $USER_ID" | jq .
echo ""


