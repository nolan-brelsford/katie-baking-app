#!/bin/bash

# Assign arguments to variables for clarity
SEARCH_TERM=$1
ZIPCODE=$2
CLIENT_CREDENTIALS=$3

# Encode credentials
CREDENTIALS=$(printf "%s" "$CLIENT_CREDENTIALS" | base64)

# Get token
# The --silent flag (-s) is added to hide the progress meter
curl -s -X POST \
  'https://api.kroger.com/v1/connect/oauth2/token' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -H "Authorization: Basic $CREDENTIALS" \
  -d 'grant_type=client_credentials&scope=product.compact' \
  --output token.json

# Extract token
TOKEN=$(cat token.json | grep -o '"access_token":"[^"]*' | cut -d'"' -f4 | tr -d '\n\r')

# Get top store location
curl -s -X GET \
  "https://api.kroger.com/v1/locations?filter.zipCode.near=$ZIPCODE&filter.limit=1" \
  -H "Authorization: Bearer $TOKEN" \
  -H 'Cache-Control: no-cache' \
  --output stores.json

# Extract location id
LOCATION_ID=$(cat stores.json | grep -o '"locationId":"[^"]*' | cut -d'"' -f4 | tr -d '\n\r')

# Get products and print the output to stdout
curl -s -X GET \
  "https://api.kroger.com/v1/products?filter.term=$SEARCH_TERM&filter.locationId=$LOCATION_ID" \
  -H "Authorization: Bearer $TOKEN" \
  -H 'Cache-Control: no-cache'