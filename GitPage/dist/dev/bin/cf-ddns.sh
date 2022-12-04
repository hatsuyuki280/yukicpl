#!/bin/bash
target_Domain_name="ddns.example.com"
CF_API_EMAIL="xxx@example.com"
CF_API_KEY="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
CF_ZONE_ID="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
CF_RECORD_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$CF_ZONE_ID/dns_records?type=A&name=$target_Domain_name" \
     -H "X-Auth-Email: $CF_API_EMAIL" \
     -H "X-Auth-Key: $CF_API_KEY" \
     -H "Content-Type: application/json" | jq -r '.result[0].id')

CF_IP=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$CF_ZONE_ID/dns_records/$CF_RECORD_ID" \
        -H "X-Auth-Email: $CF_API_EMAIL" \
        -H "X-Auth-Key: $CF_API_KEY" \
        -H "Content-Type: application/json" | jq -r '.result.content')

REAL_IP=$(curl -4s https://api.ipify.org)

if [ "$CF_IP" != "$REAL_IP" ]; then
    curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$CF_ZONE_ID/dns_records/$CF_RECORD_ID" \
        -H "X-Auth-Email: $CF_API_EMAIL" \
        -H "X-Auth-Key: $CF_API_KEY" \
        -H "Content-Type: application/json" \
        --data '{"type":"A","name":"'$target_Domain_name'","content":"'$REAL_IP'","ttl":1,"proxied":false}' | jq -r '.success'
fi