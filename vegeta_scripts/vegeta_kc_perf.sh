#!/bin/bash
echo "Running vegeta benchmark..."

CLIENT_SECRET="8eaa875c-90e5-4923-9686-784d9efb4ee9"
CLIENT_ID="performance"

USERNAME="m.yanivn@c-b4.com"
PASSWORD="123"

SCHEME="https"

KEYCLOAK_TOKEN_URL="staging-wcs.c-b4.com/auth/realms/unifiedpush-installations/protocol/openid-connect/token"
KEYCLOAK_ENTITLEMENT_URL="staging-wcs.c-b4.com/auth/realms/unifiedpush-installations/authz/entitlement/performance"
KEYCLOAK_USERINFO_URL="staging-wcs.c-b4.com/auth/realms/unifiedpush-installations/protocol/openid-connect/userinfo"
KEYCLOAK_REFRESH_URL="staging-wcs.c-b4.com/auth/realms/unifiedpush-installations/protocol/openid-connect/token"
KEYCLOAK_GITHUB_TOKEN_URL="staging-wcs.c-b4.com/auth/realms/unifiedpush-installations/broker/github/token"
MY_SPACE_NAME="Default Resource"


#VEGETA_RATE=(10 50 100 150 200 250 300 350 400 450 500)
#VEGETA_DURATION=(30 30 30 30 30 30 30 30 30 30 30)


#echo "POST $SCHEME://$KEYCLOAK_TOKEN_URL" > targets
#echo "client_id=${CLIENT_ID}&client_secret=${CLIENT_SECRET}&username=${USERNAME}&password=${PASSWORD}&grant_type=password" > body.txt

#iter=0
#for i in "${VEGETA_RATE[@]}"
#do
#   echo $i
#   echo $VEGETA_DURATION[$iter]
#   vegeta -profile cpu attack -body=body.txt -header="Content-Type:application/x-www-form-urlencoded" -targets=targets -rate=$i -duration=30s > results_token_$i.bin
#   iter=$(expr ${iter} + 1 )
#   vegeta report -inputs results_token_$i.bin
#
#   sleep 300
#done


VEGETA_RATE=(250)
VEGETA_DURATION=10s

for i in "${VEGETA_RATE[@]}"
do

   echo "client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET&username=$USERNAME&password=$PASSWORD&grant_type=password"
   TOKENS=$(curl -H "Content-Type:application/x-www-form-urlencoded" -XPOST $SCHEME://$KEYCLOAK_TOKEN_URL --data "client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET&username=$USERNAME&password=$PASSWORD&grant_type=password")
   echo "Tokens: $TOKENS"
   ACCESS_TOKEN=$(echo $TOKENS | jq .access_token | tr -d '"')
   echo "Access token: $ACCESS_TOKEN"


   echo "user info..."
   curl -H "Content-Type:application/json;charset=UTF-8" -XGET $SCHEME://$KEYCLOAK_USERINFO_URL -H "Authorization: Bearer $ACCESS_TOKEN"
   echo "GET $SCHEME://$KEYCLOAK_USERINFO_URL" > targets
   /home/yanivn/go/bin/vegeta -profile cpu attack -header="Authorization: Bearer $ACCESS_TOKEN" -header="Content-Type:application/json" -targets=targets -rate=$i -duration=$VEGETA_DURATION > results_userinfo_$i.bin
   cat results_userinfo_$i.bin | /home/yanivn/go/bin/vegeta report
done

for i in "${VEGETA_RATE[@]}"
do

   echo "client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET&username=$USERNAME&password=$PASSWORD&grant_type=password"
   TOKENS=$(curl -H "Content-Type:application/x-www-form-urlencoded" -XPOST $SCHEME://$KEYCLOAK_TOKEN_URL --data "client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET&username=$USERNAME&password=$PASSWORD&grant_type=password")
   echo "Tokens: $TOKENS"
   ACCESS_TOKEN=$(echo $TOKENS | jq .access_token | tr -d '"')
   echo "Access token: $ACCESS_TOKEN"

   REFRESH_TOKEN=$(echo $TOKENS | jq .refresh_token | tr -d '"')
   echo "Refresh token: $REFRESH_TOKEN"
    
   echo "refresh tokens..."
   curl -H "Content-Type:application/x-www-form-urlencoded" -XPOST $SCHEME://$KEYCLOAK_REFRESH_URL --data "client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET&grant_type=refresh_token&refresh_token=$REFRESH_TOKEN"
   echo "POST $SCHEME://$KEYCLOAK_REFRESH_URL" > refresh-targets
   echo "grant_type=refresh_token&refresh_token=$REFRESH_TOKEN&client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET" > refresh-body.json
   echo "@/home/yanivn/keycloak-performance-scripts/vegeta_scripts/refresh-body.json" >> refresh-targets
   /home/yanivn/go/bin/vegeta -profile cpu attack -header="Content-Type:application/x-www-form-urlencode" -targets=refresh-targets -rate=$i -duration=$VEGETA_DURATION > results_refresh_$i.bin
   cat results_refresh_$i.bin | /home/yanivn/go/bin/vegeta report
done

#for i in "${VEGETA_RATE[@]}"
#do
#
#  echo "client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET&username=$USERNAME&password=$PASSWORD&grant_type=password"
#  TOKENS=$(curl -H "Content-Type:application/x-www-form-urlencoded" -XPOST $SCHEME://$KEYCLOAK_TOKEN_URL --data "client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET&username=$USERNAME&password=$PASSWORD&grant_type=password")
#  echo "Tokens: $TOKENS"
#  ACCESS_TOKEN=$(echo $TOKENS | jq .access_token | tr -d '"')
#  echo "Access token: $ACCESS_TOKEN"
#
#   echo "github token..."
#   curl -H "Content-Type:application/json" -XGET $SCHEME://$KEYCLOAK_GITHUB_TOKEN_URL -H "Authorization: Bearer $ACCESS_TOKEN"
#   echo "GET $SCHEME://$KEYCLOAK_GITHUB_TOKEN_URL" > targets
#   vegeta -profile cpu attack -header="Authorization: Bearer $ACCESS_TOKEN" -header="Content-Type:application/json" -targets=targets -rate=$i -duration=$VEGETA_DURATION > results_github_$i.bin
#   cat results_github_$i.bin | vegeta report
#
#   sleep 300
#done

for i in "${VEGETA_RATE[@]}"
do

   echo "client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET&username=$USERNAME&password=$PASSWORD&grant_type=password"
   TOKENS=$(curl -H "Content-Type:application/x-www-form-urlencoded" -XPOST $SCHEME://$KEYCLOAK_TOKEN_URL --data "client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET&username=$USERNAME&password=$PASSWORD&grant_type=password")
   echo "Tokens: $TOKENS"
   ACCESS_TOKEN=$(echo $TOKENS | jq .access_token | tr -d '"')
   echo "Access token: $ACCESS_TOKEN"

   echo "entitlement..."
   curl -H "Content-Type:application/json;charset=UTF-8" -XPOST $SCHEME://$KEYCLOAK_ENTITLEMENT_URL --data '{"permissions":[{"resource_set_name":"Default Resource"}]}' -H "Authorization: Bearer $ACCESS_TOKEN"
   echo "POST $SCHEME://$KEYCLOAK_ENTITLEMENT_URL" > targets
   echo '{"permissions":[{"resource_set_name":"Default Resource"}]}' > body.json
   /home/yanivn/go/bin/vegeta -profile cpu attack -body=body.json -header="Authorization: Bearer $ACCESS_TOKEN" -header="Content-Type:application/json" -targets=targets -rate=$i -duration=$VEGETA_DURATION > results_entitlement_$i.bin
   /home/yanivn/go/bin/vegeta report -inputs results_entitlement_$i.bin

done

echo "Benchmark is completed!"
