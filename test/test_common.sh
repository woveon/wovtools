#!/usr/bin/env bash

if [ "${KOPS_CLUSTER_NAME}" == "" ]; then
  tr_comment "KOPS_CLUSTER_NAME is not set. See your available clusters with 'kops get clusters'."
  exit 1
else
  USEHOSTEDZONE="Z1NR42SJ9ZADVC"
  KOPSSPLIT=(${KOPS_CLUSTER_NAME//./ })
  if [ ${#KOPSSPLIT[@]} -ne 3 ]; then echo "KOPS_CLUSTER_NAME should be named CLUSTER.DOMAIN, with CLUSTER as per WovTools naming."; fi
  USECLUSTER="${KOPSSPLIT[0]}"
  USEDOMAIN="${KOPSSPLIT[1]}.${KOPSSPLIT[2]}"
fi

TESTDIR=`pwd`
MASTER=$(basename ${TESTDIR})
TEST=test1
TESTME=testme
PROJ="${TEST}"
LADIR="${TESTDIR}/${MASTER}localarchives"
RRDIR="${TESTDIR}/${MASTER}remoterepo"
TESTREPODIR="${TESTDIR}/testremoterepo"
PROJDIR="${TESTDIR}/${TEST}"
MSCODE=X

mkdir -p "${TESTREPODIR}" || exit 1
mkdir -p "${RRDIR}" || exit 1
mkdir -p "${LADIR}" || exit 1
 

# --------------------------------------------------------------------- 
tr_h3      "Test Assuming:"
# --------------------------------------------------------------------- 
tr_comment "        Test Dir : TESTDIR       : ${TESTDIR}"
tr_comment "  Master Project : MASTER        : ${MASTER}"
tr_comment "         Project : PROJ          : ${PROJ}"
tr_comment "       Test 'ME' : TESTME        : ${TESTME}"
tr_comment "     Project Dir : PROJDIR       : ${PROJDIR}"
tr_comment "   Local Archive : LADIR         : ${LADIR}"
tr_comment "       Test Repo : TESTREPODIR   : ${TESTREPODIR}"
tr_comment "         Cluster : USECLUSTER    : ${USECLUSTER}"
tr_comment "         Domain  : USEDOMAIN     : ${USEDOMAIN}"
tr_comment " AWS Hosted Zone : USEHOSTEDZONE : ${USEHOSTEDZONE}"


# --------------------------------------------------------------------- 
# --------------------------------------------------------------------- 
function tcUseTestingContext()
{
  local wc=$(kubectl config current-context)
  tr_comment "use a testing K8s context of '${USECLUSTER}-${TEST}-${TESTME}', protecting current context of '${wc}'"
  tr_protectcmds <<EOF
echo "...restoring K8s context from testing context of :'${USECLUSTER}-${TEST}-${TESTME}'"
kubectl config use-context "${wc}"
EOF


  kubectl config get-contexts "${USECLUSTER}-${PROJ}-${TESTME}" > /dev/null
  if [ $? -ne 0 ]; then
    tr_comment "...creating testing context '${USECLUSTER}-${PROJ}-${TESTME}'"
    kubectl config set-context "${USECLUSTER}-${PROJ}-${TESTME}" --cluster="${USECLUSTER}-${PROJ}-${PROJ}.${USEDOMAIN}" --namespace="${PROJ}-${TESTME}" --user="${USECLUSTER}.${USEDOMAIN}" 
    if [ $? -ne 0 ]; then
      echo "ERROR: could not create testing K8s context"
      exit 1
    fi
  fi
  kubectl config use-context "${USECLUSTER}-${TEST}-${TESTME}"
}


# --------------------------------------------------------------------- 
# Completely wipes a WovDB
# --------------------------------------------------------------------- 
function tcWipeWovDB()
{
  local DB_name=$1
  local USEORIGIN=$2

  if [ "$USEORIGIN" == "" ]; then USEORIGIN="here"; fi

  tr_h1 "tcWipeWovDB"

  tr_comment "test wov-db Adb existence"
  wov-db --context "${USEORIGIN}:${USECLUSTER}-${TEST}-${TESTME}"  ${DB_name} --test 2> /dev/null
  if [ $? -eq 0 ]; then
    tr_comment "...stopping WovDB ${DB_name} in '${USEORIGIN}:${USECLUSTER}-${TEST}-${TESTME}'"
    wov-db --context "${USEORIGIN}:${USECLUSTER}-${TEST}-${TESTME}" ${DB_name} --stop
  else
    tr_comment "...no currently running Adb in '${USEORIGIN}:${USECLUSTER}-${TEST}-${TESTME}'"
  fi

  rm -Rf wovtools/secrets/${DB_name}_*.json
  rm -Rf wovtools/db/archive/${DB_name}
  rm -Rf wovtools/db/archive/${DB_name}.json
  rm -Rf wovtools/db/${DB_name}.deltas

  # remove entries from config for database in dev"
  jq -r 'del( .secrets.dev[] | select( . == "'${DB_name}'.json" or . == "'${DB_name}'_dev.json" ) )' wovtools/config.json > wovtools/config.json.1 ; mv wovtools/config.json.1 wovtools/config.json
  jq -r 'del( .secrets.prod[] | select( . == "'${DB_name}'.json" or . == "'${DB_name}'_prod.json" ) )' wovtools/config.json > wovtools/config.json.1 ; mv wovtools/config.json.1 wovtools/config.json
  jq -r 'del( .secrets.'${TESTME}'[] | select( . == "'${DB_name}'.json" or . == "'${DB_name}"_${TESTME}"'.json" ) )' wovtools/myconfig.json > wovtools/myconfig.json.1 ; mv wovtools/myconfig.json.1 wovtools/myconfig.json
}

