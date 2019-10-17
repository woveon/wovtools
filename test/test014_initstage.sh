#!/usr/bin/env bash
. /usr/local/bin/wtrunner

WOV_DEBUGMODE=1
DOECHO=2
#TEST=test1
#TESTDIR=`pwd`
##MASTER=$(basename ${TESTDIR})
#PROJ="${TEST}"
#LADIR="${TESTDIR}/${MASTER}localarchives"
#RRDIR="${TESTDIR}/${MASTER}remoterepo"
#mkdir -p "${RRDIR}"
#mkdir -p "${LADIR}"
#PROJDIR="${TESTDIR}/${TEST}"
#TESTME=testme # $(cat ${HOME}/.wovtools | jq -r '.me')
PID=$$


tr_h1      "Test ${0}"
. test_common.sh
# tcUseTestingContext


tr_protectfile "wovtools/myconfig.json"

#tr_comment "set .me to '${TESTME}'."
#cat ~/.wovtools | jq -r ".me=\"${TESTME}\"" > ~/.wovtools.1
#if [ $? -eq 0 ]; then mv ~/.wovtools.1 ~/.wovtools; 
#else rm ~/.wovtools.1; tr_comment "Failed changing .me to '${TESTME}'"; exit 2; fi


{
  tr_section 'dirchecks'
  if [ ! -d "${PROJDIR}" ]; then l_error "No '${PROJDIR}'. Run test011_init.sh."; exit 1; fi
  tr_dir ${PROJ}
  tr_section '/dirchecks'
}


{
  tr_section "k8scontext"

  tr_comment "ensure a valid K8s context. "
  while [ true ]; do

    # test connection
    kubectl config get-contexts
    if [ $? -ne 0 ]; then
      tr_comment "You need to set a valid Kubernetes context for this test (not $(kubectl config current-context))."
      tr_comment "Try 'kubectl config set-context X'.";
    fi

    tr_comment "Looking for a context for this cluster to temporarily use (so can query Kubernetes configuration)"
    A=$(kubectl config get-contexts | \grep "${USECLUSTER}" | head -n 1 | awk '{print $1}')
    if [ "$A" != "" ]; then
      kubectl config use-context "$A"
      if [ $? -eq 0 ]; then break; else echo "...failed to use config '${A}'."; fi
    fi

    read -e -p "Change K8s context to an actual context : " -i "${USECLUSTER}-${PROJ}-$(jq -r ".me" ~/.wovtools)" A
    kubectl config use-context $A
    if [ $? -ne 0 ]; then "Failed to set. Exiting."; exit 1; fi
  done

  tr_run "show kubernetes context" "kubectl config current-context"

  tr_section "/k8scontext"
}


{
  tr_section 'initstage'
  # NOTE: can really only be run once! run ./test011_init.sh
  #tr_run "remove any existing namespace"     "kubectl delete namespace '${PROJ}-${TESTME}'"
  tr_test "delete testing namespace for now, as it will be created below" "kubectl delete namespace \"${PROJ}-${TESTME}\"" 0 -1

  tr_run "remove any existing k8s context"   "kubectl config delete-context '${USECLUSTER}-${PROJ}-${TESTME}'"
  tr_run "remote .secrets.testme from wovtools/myconfig.json" \
    "cat wovtools/myconfig.json | jq -r 'del( .secrets.testme)' > wovtools/myconfig.json.1 ; mv wovtools/myconfig.json.1 wovtools/myconfig.json"

  if [ -e "wovtools/secrets/test_${TESTME}.json" ]; then
    tr_run "move test_${TESTME}.json secret so can test that case" \
      "mv wovtools/secrets/test_${TESTME}.json /tmp/test_${TESTME}.json.${PID}"

    # remove from repo
    git -C wovtools/secrets rm test_${TESTME}.json
    git -C wovtools/secrets commit -a -m "removed test_${TESTME}.json"
    git -C wovtools/secrets push
  fi


  tr_section '/initstage'
}

# tr_vverbose
{
  tr_section 'creation'
  tr_test "fails cluster config creation" "wov-init-stage ${TESTME}" 102 -1

  tr_comment "add '${TESTME}' stage to myconfig.json"
  { cat  wovtools/myconfig.json; cat <<EOF ; } | jq -s ".[0] * .[1]" > wovtools/myconfig.json.1
{
  "secrets" : {
    "${TESTME}" : [ "test.json","test_${TESTME}.json","cluster_mymanaged.json","repositories.json" ]
  }
}
EOF
  if [ $? -ne 0 ]; then exit 1; fi
  mv wovtools/myconfig.json.1 wovtools/myconfig.json


  tr_test "fails with missing secrets file" "wov-init-stage ${TESTME}" 103 -1

  tr_run "move test_${TESTME}.json secret back" \
    "mv /tmp/test_${TESTME}.json.${PID} wovtools/secrets/${MASTER}_${TESTME}.json"

  tr_test "fails namespace checks" "wov-init-stage -vv --debugmode --test ${TESTME}" 106 -1


  # tr_comment "For Debugging, K8s contexts"
  # kubectl config get-contexts 

  tr_test "creates namespace, fails context checks" "wov-init-stage -vv --debugmode --create-ns --no-create-context ${TESTME}" 107 -1

  tr_run "show all contexts now" "kubectl config get-contexts"
  tr_run "show kubernetes context" "kubectl config current-context"

  tr_test "creates context, fails git because added file not added/checked in" \
    "wov-init-stage -vv --debugmode --create-context ${TESTME}" 108 -1

  tr_run "show all contexts now" "kubectl config get-contexts"
  tr_run "show current kubernetes context" "kubectl config current-context"

  tr_vverbose
  tr_run "git add/commit/push" \
    "git -C wovtools/secrets add ${MASTER}_${TESTME}.json; git -C wovtools/secrets commit -a -m 'added ${MASTER}_${TESTME}.json'; git -C wovtools/secrets push"

  tr_run "show kubernetes" "kubectl config current-context"

  tr_test "passes finally" "wov-init-stage ${TESTME}" 0 -1


  tr_test "switch stage" "wov-stage -vv --debugmode ${TESTME}" 0 -1

  tr_section '/creation'
}

tr_popdir
tr_results
