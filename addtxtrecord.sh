#!/bin/bash

# API Key from DNS provider in '.key' file
API_KEY=$(cat .key)

# Random string to add to TXT record at '_acme-challenge' subdomain
TXT_RECORD="$1"

curl https://developers.hostinger.com/api/dns/v1/zones/yourdomain.com \
  --request PUT \
  --header 'Content-Type: application/json' \
  --header "Authorization: Bearer $API_KEY" \
  --data "{
  \"overwrite\": true,
  \"zone\": [
    {
      \"name\": \"_acme-challenge\",
      \"records\": [
        {
          \"content\": \"$TXT_RECORD\"
        }
      ],
      \"ttl\": 60,
      \"type\": \"TXT\"
    }
  ]
}"
