#!/usr/bin/env bash
. /usr/local/bin/wtrunner

TEST=test1
WOV_DEBUGMODE=1
DOECHO=2
TESTDIR=`pwd`
MASTER=$(basename ${TESTDIR})
PROJ="${TEST}"
LADIR="${TESTDIR}/${MASTER}localarchives"
RRDIR="${TESTDIR}/${MASTER}remoterepo"
mkdir -p "${RRDIR}"
mkdir -p "${LADIR}"
PROJDIR="${TESTDIR}/${TEST}"
TESTME=testme # $(cat ${HOME}/.wovtools | jq -r '.me')
PID=$$

#tr_protectfile "wovtools/myconfig.json"

tr_h1      "Test ${0}"
. test_common.sh


{
  tr_section 'dirchecks'
  if [ ! -d "${PROJDIR}" ]; then l_error "No '${PROJDIR}'. Run test011_init.sh."; exit 1; fi
  tr_dir ${PROJ}
  tr_section '/dirchecks'
}




{
  tr_section 'initstage'
  # NOTE: can really only be run once! run ./test011_init.sh
  tr_run "remove any existing namespace"     "kubectl delete namespace '${PROJ}-${TESTME}'"
  tr_run "remove any existing k8s context"   "kubectl config delete-context '${USECLUSTER}-${PROJ}-${TESTME}'"
  tr_run "remove test_${TESTME}.json secret" "rm -f wovtools/secrets/test_${TESTME}.json"

  tr_comment "ensure current K8s context is valid"

  while [ true ]; do
    kubectl config get-contexts | grep "$(kubectl config current-context)"
    if [ $? -ne 0 ]; then
      tr_comment "You need to set a valid Kubernetes context for this test (not $(kubectl config current-context))."
      tr_comment "Try 'kubectl config set-context X'.";
    else
      break;
    fi

    read -e -p "Change K8s context to : " -i "${USECLUSTER}-${PROJ}-$(jq -r ".me" ~/.wovtools)" A
    kubectl config use-context $A
    if [ $? -ne 0 ]; then "Failed to set. Exiting."; exit 1; fi
  done

  tr_section '/initstage'
}



tr_vverbose
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
  tr_run "add missing file" "echo '{}' > wovtools/secrets/test_${TESTME}.json"


  tr_test "fails namespace checks" "wov-init-stage -vv --debugmode --test ${TESTME}" 106 -1
  tr_test "creates namespace, fails context checks" "wov-init-stage -vv --debugmode --create-ns --no-create-context ${TESTME}" 107 -1

  tr_test "creates context, fails git because added file not added/checked in" \
    "wov-init-stage -vv --debugmode --create-context ${TESTME}" 108 -1

  tr_run "git add/commit/push" \
    "git -C wovtools/secrets add test_${TESTME}.json; git -C wovtools/secrets commit -a -m 'added test_${TESTME}.json'; git -C wovtools/secrets push"

  tr_test "passes finally" "wov-init-stage ${TESTME}" 0 -1

  exit 1
  tr_test "switch stage" "wov-stage -vv --debugmode ${TESTME}" 0 -1

  tr_section '/creation'
}

tr_popdir
tr_results
