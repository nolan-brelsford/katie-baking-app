#!/bin/bash

# Assign arguments to variables for clarity
SEARCH_TERM=$1
ZIPCODE=$2
CLIENT_CREDENTIALS=$3

# Encode credentials
CREDENTIALS=$(printf "%s" "$CLIENT_CREDENTIALS" | base64)

# Get token
# The first curl command gets the token and pipes its JSON output directly to the TOKEN variable assignment.
TOKEN=$(curl -s -X POST \
  'https://api.kroger.com/v1/connect/oauth2/token' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -H "Authorization: Basic $CREDENTIALS" \
  -d 'grant_type=client_credentials&scope=product.compact' | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)

# Get top store location
# The second curl command gets the location and pipes its JSON output directly to the LOCATION_ID variable assignment.
LOCATION_ID=$(curl -s -X GET \
  "https://api.kroger.com/v1/locations?filter.zipCode.near=$ZIPCODE&filter.limit=1" \
  -H "Authorization: Bearer $TOKEN" \
  -H 'Cache-Control: no-cache' | grep -o '"locationId":"[^"]*' | cut -d'"' -f4)

# Get products and print the output to stdout
# The final curl command's output is sent to stdout, which is captured by the Python script.
curl -s -X GET \
  "https://api.kroger.com/v1/products?filter.term=$SEARCH_TERM&filter.locationId=$LOCATION_ID" \
  -H "Authorization: Bearer $TOKEN" \
  -H 'Cache-Control: no-cache'