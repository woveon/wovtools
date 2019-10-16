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
