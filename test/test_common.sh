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

tr_h3      "Assuming:"
tr_comment "         Cluster : ${USECLUSTER}"
tr_comment "         Domain  : ${USEDOMAIN}"
tr_comment " AWS Hosted Zone : ${USEHOSTEDZONE}"
