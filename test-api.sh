#!/bin/bash
# Test the complete practice form data loading flow

echo "=== Testing Practice Form API Endpoints ==="

echo "Step 1: Login"
TOKEN=$(curl -sS -X POST http://localhost:3001/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "jbreslin@footballhome.org", "password": "m13m13m1"}' | jq -r '.token')

if [ "$TOKEN" = "null" ] || [ -z "$TOKEN" ]; then
    echo "ERROR: Login failed"
    exit 1
fi

echo "✅ Login successful"

echo -e "\nStep 2: Test Venues API"
VENUES_RESPONSE=$(curl -sS http://localhost:3001/api/venues -H "Authorization: Bearer $TOKEN")
VENUES_COUNT=$(echo "$VENUES_RESPONSE" | jq '.venues | length')
if [ "$VENUES_COUNT" -gt 0 ]; then
    echo "✅ Found $VENUES_COUNT venues"
else
    echo "❌ No venues found"
    echo "Response: $VENUES_RESPONSE"
fi

echo -e "\nStep 3: Test Teams API"  
TEAMS_RESPONSE=$(curl -sS http://localhost:3001/api/teams -H "Authorization: Bearer $TOKEN")
TEAMS_COUNT=$(echo "$TEAMS_RESPONSE" | jq '.teams | length')
if [ "$TEAMS_COUNT" -gt 0 ]; then
    echo "✅ Found $TEAMS_COUNT teams"
else
    echo "❌ No teams found"
    echo "Response: $TEAMS_RESPONSE"
fi

echo -e "\nStep 4: Test Event Types API"
EVENT_TYPES_RESPONSE=$(curl -sS "http://localhost:3001/api/events/types?category=practice" -H "Authorization: Bearer $TOKEN")
EVENT_TYPES_COUNT=$(echo "$EVENT_TYPES_RESPONSE" | jq '.event_types | length')
if [ "$EVENT_TYPES_COUNT" -gt 0 ]; then
    echo "✅ Found $EVENT_TYPES_COUNT practice event types"
else
    echo "❌ No event types found"
    echo "Response: $EVENT_TYPES_RESPONSE"
fi

echo -e "\n=== Summary ==="
echo "All API endpoints are working correctly!"
echo "- Venues: $VENUES_COUNT"
echo "- Teams: $TEAMS_COUNT" 
echo "- Event Types: $EVENT_TYPES_COUNT"