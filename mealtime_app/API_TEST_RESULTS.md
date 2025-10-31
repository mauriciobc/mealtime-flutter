# API Test Results - Home Screen Data Loading

## Test Date
28 Oct 2025

## Summary
Login endpoint works but `/cats` and `/households` return 401 Unauthorized with the backend token.

## Test Results

### ✅ Login Endpoint - `/api/auth/mobile`
- **Status**: SUCCESS
- **Response Structure**: 
  ```json
  {
    "success": true,
    "user": {
      "id": "...",
      "auth_id": "...",
      "full_name": "Mauricio Castro",
      "email": "mauriciobc@gmail.com",
      "household_id": "786f7655-b100-45d6-b75e-c2a85add5e5b",
      "household": {
        "id": "786f7655-b100-45d6-b75e-c2a85add5e5b",
        "name": "House of Cats",
        "members": [...]
      }
    },
    "access_token": "eyJhbGci...",
    "refresh_token": "...",
    "expires_in": 3600,
    "token_type": "Bearer"
  }
  ```
- **Token Type**: Supabase JWT
- **Note**: Response has all fields at top level, not wrapped in `data` object initially

### ❌ Cats Endpoint - `/api/cats`
- **Status**: FAIL (401 Unauthorized)
- **Error**: `{"error": "Unauthorized"}`
- **Headers Used**:
  - `Authorization: Bearer <token>`
  - `X-User-ID: <user_id>`
- **Problem**: Backend rejects the token from `/auth/mobile` login

### ❌ Households Endpoint - `/api/households`
- **Status**: FAIL (401 Unauthorized)
- **Error**: `{"error": "Unauthorized"}`
- **Headers Used**:
  - `Authorization: Bearer <token>`
  - `X-User-ID: <user_id>`
- **Problem**: Backend rejects the token from `/auth/mobile` login

### ⚠️ Schedules Endpoint - `/api/schedules`
- **Status**: FAIL (400 Bad Request)
- **Error**: `{"error": "Dados inválidos", "details": "Household ID is required"}`
- **Note**: This endpoint expects a `household_id` parameter

## Key Findings

1. **Token Format**: The login endpoint returns a Supabase JWT token
2. **Backend Rejection**: The backend API `/cats` and `/households` endpoints reject Supabase tokens
3. **Expected vs Actual**: The backend `/auth/mobile` endpoint accepts Supabase authentication but the data endpoints don't

## Recommendations

The backend needs to be fixed. The issue is that:
- The `/auth/mobile` endpoint successfully authenticates and returns a Supabase token
- But the `/cats` and `/households` endpoints reject this same token

This suggests the backend is not properly configured to accept Supabase JWTs for these endpoints.


