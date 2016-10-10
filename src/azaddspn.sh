#!/bin/bash

THECMD=$0
APPNAME=$1
APPPWD=$2

if [[ "" == ${APPNAME} ]]; then
  echo "You need to specify an app name after your docker command, ex : ${THECMD} 'AppName'"
  exit 1
fi

if [[ "" == ${APPPWD} ]]; then
  echo "*** No password specified, generating one using urandom"
  echo
  PASSWORD=$(env LC_CTYPE=C tr -dc "a-zA-Z0-9" < /dev/urandom | head -c 15)
fi
if [[ "" != ${APPPWD} ]]; then
  PASSWORD=$APPPWD
fi

azure login

if [ -z "$SUBSCRIPTIONNAME" ]; then
  echo "Successfully logged"
  echo " -------- > Pick your subscription : "
  options=($(azure account list --json | jq -r 'map(select(.state == "Enabled"))|.[]|.name + ":" + .id' | sed -e 's/ /_/g'))
  select opt in "${options[@]}"
  do
          SUBSCRIPTIONNAME=`echo $opt | awk -F ':' '{print $1}'`
          break
  done
fi

echo "**** Using subscription : ${SUBSCRIPTIONNAME}"

TENANTID=$(azure account list --json | jq "map(select(.isDefault == true)) | .[0].tenantId" | sed -e 's/\"//g')
SUBSCRIPTIONID=$(azure account list --json | jq "map(select(.isDefault == true)) | .[0].id" | sed -e 's/\"//g')

if [[ "" == ${TENANTID} ]]; then
    echo "!!! Error - Tenant id. !!!"
    exit 1
fi
echo "*** Validating if this application is not already there... You can ignore the parse error message..."
APPALREDAYTHERE=$(azure ad app show -c ${APPNAME} --json | jq ".[0].displayName" )

if [[ "" != ${APPALREDAYTHERE} ]]; then
    echo "!!! This application name is already taken !!!"
    exit 1
fi

echo "**** Creating AD application ${APPNAME}"

azure ad app create -n ${APPNAME} -i http://${APPNAME} -m http://${APPNAME} -p ${PASSWORD} --json > logApp.json

APPID=$(jq .appId logApp.json | sed -e s/\"//g)

echo "**** Application created with ID=${APPID}"
if [[ "" == ${APPID} ]]; then
    echo "!!! Error - APP ID !!!"
    exit 1
fi

echo "**** Creating SPN"
azure ad sp create --applicationId ${APPID}  --json > logAppSP.json

SPOBJECTID=$(jq .objectId logAppSP.json | sed -e 's/\"//g')

echo "SPN created with ID=${SPOBJECTID}"
if [[ "" == ${SPOBJECTID} ]]; then
    echo "!!! Error - SP Object !!!"
    exit 1
fi

echo "*** Waiting 15 sec to applying for parameters"
sleep 15

echo "Attributing contributor role for ${SPOBJECTID} in subscription ${SUBSCRIPTIONNAME}"
azure role assignment create --objectId ${SPOBJECTID} --roleName Contributor --json > logRole.json

echo

echo "================== Informations about your new App =============================="
echo "Subscription ID                    ${SUBSCRIPTIONID}"
echo "Subscription Name                  ${SUBSCRIPTIONNAME}"
echo "Service Principal Client ID:       ${APPID}"
echo "Service Principal Key:             ${PASSWORD}"
echo "Tenant ID:                         ${TENANTID}"
echo "================================================================================="
echo
echo "Thanks for using this container, if you have questions or issues : https://github.com/julienstroheker/DockerAzureSPN"