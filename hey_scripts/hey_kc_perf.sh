#!/bin/bash

echo "Getting access token..."

CLIENT_SECRET="8eaa875c-90e5-4923-9686-784d9efb4ee9"
CLIENT_ID="performance"
KEYCLOAK_TOKEN_URL="staging-wcs.c-b4.com/auth/realms/unifiedpush-installations/protocol/openid-connect/token"
USERNAME="m.yanivn@c-b4.com"
PASSWORD="123"
KEYCLOAK_RPT_URL="staging-wcs.c-b4.com/auth/realms/unifiedpush-installations/authz/entitlement/performance"
RESOURCE_NAME="Default Resource"

HEY_REQUESTS_TOKEN=(10 100)
HEY_CONCURRENT_REQS_TOKEN=(1 100)
iter=0
for i in "${HEY_REQUESTS_TOKEN[@]}"
do
   echo $i
   /home/yanivn/go/bin/hey -m POST -T application/x-www-form-urlencoded -d "client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET&username=$USERNAME&password=$PASSWORD&grant_type=password" -n $i -c ${HEY_CONCURRENT_REQS_TOKEN[$iter]}  https://$KEYCLOAK_TOKEN_URL

done


HEY_REQUESTS=(100 1000 10000)
HEY_CONCURRENT_REQS=(10 100 1000)

iter=0
for i in "${HEY_REQUESTS[@]}"
do

   echo "client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET&username=$USERNAME&password=$PASSWORD&grant_type=password"
   TOKENS=$(curl -H "Content-Type:application/x-www-form-urlencoded" -XPOST https://$KEYCLOAK_TOKEN_URL --data "client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET&username=$USERNAME&password=$PASSWORD&grant_type=password")

   echo "Tokens: $TOKENS"

   ACCESS_TOKEN=$(echo $TOKENS | jq .access_token | tr -d '"')

   echo "Access token: $ACCESS_TOKEN"

   curl -H "Content-Type:application/json;charset=UTF-8" -XPOST https://$KEYCLOAK_RPT_URL --data "{\"permissions\":[{\"resource_set_name\":\"${RESOURCE_NAME}\"}]}" -H "Authorization: Bearer $ACCESS_TOKEN"

   echo $i
   /home/yanivn/go/bin/hey -H "Authorization: Bearer $ACCESS_TOKEN" -m POST -T application/json -d "{\"permissions\":[{\"resource_set_name\":\"${RESOURCE_NAME}\"}]}" -n $i -c ${HEY_CONCURRENT_REQS[$iter]}  https://$KEYCLOAK_RPT_URL
   iter=$(expr ${iter} + 1 )

done
