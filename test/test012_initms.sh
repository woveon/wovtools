#!/usr/bin/env bash
. /usr/local/bin/wtrunner


WOV_DEBUGMODE=1
DOECHO=2

#TEST=test1
#TESTDIR=`pwd`
#MASTERPROJ=$(basename ${TESTDIR})
#LADIR="${TESTDIR}/${MASTERPROJ}localarchives"
#TESTREPO="${TESTDIR}/testrepo"
#mkdir -p "${TESTREPO}"
#PROJDIR="${TESTDIR}/${TEST}"
MSCODE=X


# --- used this during testing so it creates random microservices
# MSCODE=$$


tr_h1 "wov-init-ms Tests"
tr_comment "NOTE: Expects test1 project to exist, created by test001_init.sh"
. test_common.sh
tcUseTestingContext
tr_dir "${TESTDIR}/${TEST}"

# tr_protectfile "wovtools/secrets/${MASTER}_${TESTME}.json"

{
  tr_section 'prep'

  tr_comment "Using MSCode '${MSCODE}'"
  tr_run "remove files" "rm wovtools/k8s/${TEST}${MSCODE}.yaml.wov ; rm wovtools/k8s/${TEST}${MSCODE}-service.yaml.wov ; rm wovtools/k8s/${TEST}-ingress.yaml.wov"

  tr_comment "remove ${MASTER}_${TESTME}.json from secrets repo"
#  git -C wovtools/secrets rm ${MASTER}_${TESTME}.json || exit 1
#  git -C wovtools/secrets commit -a -m "removed ${MASTER}_${TESTME}.json" || exit 1
#  git -C wovtools/secrets push || exit 1


  tr_run "remove ms files" "rm -f ${TEST}${MSCODE}/src/${TEST}${MSCODE}config.sh ${TEST}${MSCODE}/src/${TEST}${MSCODE}config.js"

#  WOV_CONTEXT=$(kubectl config current-context)
#  tr_comment "use a testing K8s context of '${USECLUSTER}-${TEST}-${TESTME}', protecting current context of '${WOV_CONTEXT}'"
#  tr_protectcmds <<EOF
#echo "...restoring K8s context"
#kubectl config use-context "${WOV_CONTEXT}"
#EOF
#  kubectl config use-context "${USECLUSTER}-${TEST}-${TESTME}"

  tr_section '/prep'
}
  tr_run "master_testme secrets" "cat wovtools/secrets/${MASTER}_${TESTME}.json"


{
  tr_section 'buildmicroservice'

  tr_run "master_testme secrets" "cat wovtools/secrets/${MASTER}_${TESTME}.json"

  tr_test "make the repo only" \
    "wov-init-ms -v --repo-entry aws ${MSCODE} > /dev/null ; echo $?"  0 1 0
  tr_test "test repo exists" \
    "aws ecr describe-repositories --repository-names '${TEST}/${TEST}${MSCODE}' > /dev/null ; echo $?" 0 1 0

  tr_run "master_testme secrets" "cat wovtools/secrets/${MASTER}_${TESTME}.json"


  tr_test "make the k8s" \
    ">&2 wov-init-ms -v --k8s ${MSCODE}; echo $?"  0 1 0
  tr_test "dir exists" "[ -d wovtools/k8s ] && echo 0 || echo 1"  0 1 0 
  tr_test "k8s for service exists" "[ -f 'wovtools/k8s/${TEST}${MSCODE}-service.yaml.wov' ] && echo 0 || echo 1"  0 1 0 
  tr_test "k8s for ms exists"      "[ -f 'wovtools/k8s/${TEST}${MSCODE}.yaml.wov' ] && echo 0 || echo 1"  0 1 0 
  tr_test "k8s for ingress exists" "[ -f 'wovtools/k8s/${TEST}-ingress.yaml.wov' ] && echo 0 || echo 1"  0 1 0 
  tr_test "ingress has this ms"    "grep '${TEST}${MSCODE}' wovtools/k8s/${TEST}-ingress.yaml.wov > /dev/null ; echo $?" 0 1 0 

  tr_run "master_testme secrets" "cat wovtools/secrets/${MASTER}_${TESTME}.json"

  tr_test "make the recipe" \
    ">&2 wov-init-ms -v --recipe ${MSCODE}; echo $?"  0 1 0
  tr_test "recipe exists" "[ -f 'wovtools/msrecipes/${MSCODE}' ] && echo 0 || echo 1"  0 1 0 

  tr_run "master_testme secrets" "cat wovtools/secrets/${MASTER}_${TESTME}.json"

  tr_run "remove ms files" "rm -f ${TEST}${MSCODE}/src/${TEST}${MSCODE}config.sh ${TEST}${MSCODE}/src/${TEST}${MSCODE}config.js"
  tr_test "make the ms" \
    ">&2 wov-init-ms -v --ms ${MSCODE}; echo $?"  0 1 0
  tr_test "dir exists" "[ -d ${TEST}${MSCODE}/src ] && echo 0 || echo 1"  0 1 0 
  tr_test "config file exists" "[ -f ${TEST}${MSCODE}/src/${TEST}${MSCODE}config.sh ] && echo 0 || echo 1" 0 1 0 
  tr_vverbose
  tr_test "wov-env --cm works " "wov-env --cm ${TEST}${MSCODE}" 0 -1
  # tr_test "wov-env --cm works " "wov-env --cm ${TEST}${MSCODE} > /dev/null && echo 1" 0 1 1
  tr_test "wov-env --var port" "wov-env --var WOV_${TEST}${MSCODE}_port" 0 1 "75643"

  tr_run "cleanup" "rm -Rf ${TEST}${MSCODE}"

  tr_test "make the ms of type nodejs" \
    ">&2 wov-init-ms -v --ms-type nodejs --ms ${MSCODE}; echo $?"  0 1 0
  tr_test "dir exists" "[ -d ${TEST}${MSCODE}/src ] && echo 0 || echo 1"  0 1 0 
  tr_test "package file exists" "[ -f ${TEST}${MSCODE}/package.json ] && echo 0 || echo 1" 0 1 0 
  tr_test "config file exists" "[ -f ${TEST}${MSCODE}/src/index.js ] && echo 0 || echo 1" 0 1 0 
  tr_test "config file exists" "[ -f ${TEST}${MSCODE}/src/${TEST}${MSCODE}config.sh ] && echo 0 || echo 1" 0 1 0 
  tr_test "wov-env --cm works" "wov-env --cm ${TEST}${MSCODE} > /dev/null && echo 1" 0 1 1
  tr_test "wov-env --var port" "wov-env --var WOV_${TEST}${MSCODE}_port" 0 1 "75643"

  tr_run "cleanup" "rm -Rf ${TEST}${MSCODE}"

  tr_test "make the ms of type nodejs" \
    ">&2 wov-init-ms -v --ms-type woveonservice --ms ${MSCODE}; echo $?"  0 1 0

  tr_test "dir exists" "[ -d ${TEST}${MSCODE}/src ] && echo 0 || echo 1"  0 1 0 
  tr_test "package file exists" "[ -f ${TEST}${MSCODE}/package.json ] && echo 0 || echo 1" 0 1 0 
  cat ${TEST}${MSCODE}/package.json
  tr_test "config file exists" "[ -f ${TEST}${MSCODE}/src/index.js ] && echo 0 || echo 1" 0 1 0 
  tr_test "config file exists" "[ -f ${TEST}${MSCODE}/src/${TEST}${MSCODE}config.js ] && echo 0 || echo 1" 0 1 0 
  tr_test "wov-env --cm works" "wov-env --cm ${TEST}${MSCODE} > /dev/null && echo 1" 0 1 1
  tr_test "wov-env --var port" "wov-env --var WOV_${TEST}${MSCODE}_port" 0 1 "75643"


  tr_test "git cleanup"         "git commit -a -m 'added ${TEST}${MSCODE}' ; git push" 0 -1
  git status

  tr_vverbose
  tr_test "git secrets cleanup" "git -C wovtools/secrets add '${MASTER}_${TESTME}.json'" 0 -1 
  tr_run  "git secrets cleanup" "git -C wovtools/secrets commit -a -m 'test012 ms secrets'"
  tr_test "git secrets cleanup" "git -C wovtools/secrets push" 0 -1

}

{
  tr_section "buildsinglems"
  tr_comment "TODO"
  tr_section "/buildsinglems"
}

tr_results
