#!/bin/bash


echo "Running wrk benchmarks..."

CLIENT_SECRET="8eaa875c-90e5-4923-9686-784d9efb4ee9"
CLIENT_ID="performance"
USERNAME="m.yanivn@c-b4.com"
PASSWORD="123"
SCHEME="https"
KEYCLOAK_TOKEN_URL="staging-wcs.c-b4.com/auth/realms/unifiedpush-installations/protocol/openid-connect/token"
KEYCLOAK_ENTITLEMENT_URL="staging-wcs.c-b4.com/auth/realms/unifiedpush-installations/authz/entitlement/performance"

echo "Getting access token.."

echo "client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET&username=$USERNAME&password=$PASSWORD&grant_type=password"
TOKENS=$(curl -H "Content-Type:application/x-www-form-urlencoded" -XPOST $SCHEME://$KEYCLOAK_TOKEN_URL --data "client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET&username=$USERNAME&password=$PASSWORD&grant_type=password")
echo "Tokens: $TOKENS"
ACCESS_TOKEN=$(echo $TOKENS | jq .access_token | tr -d '"')
## entitlement
echo "Running performance test against the entitlement endpoint..."
DURATION=10s
CONNECTIONS=400
THREADS=12
wrk -t$THREADS -c$CONNECTIONS -d$DURATION -R300 ${SCHEME}://${KEYCLOAK_ENTITLEMENT_URL} -H "Authorization: Bearer $ACCESS_TOKEN" -s script_kc_authorization.lua


## Access token
echo "Running performance test against access token endpoint..."
DURATION=30s
CONNECTIONS=1
THREADS=1
wrk -t$THREADS -c$CONNECTIONS -d$DURATION -R1000 $SCHEME://$KEYCLOAK_TOKEN_URL -s script_kc_access_token.lua


echo "Benchmark is completed!"
