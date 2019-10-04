#!/usr/bin/env bash
. /usr/local/bin/wtrunner


WOV_DEBUGMODE=1
DOECHO=2
TEST=test1
TESTDIR=`pwd`
MASTERPROJ=$(basename ${TESTDIR})
LADIR="${TESTDIR}/${MASTERPROJ}localarchives"
TESTREPO="${TESTDIR}/testrepo"
mkdir -p "${TESTREPO}"
PROJDIR="${TESTDIR}/${TEST}"
MSCODE=X


# --- used this during testing so it creates random microservices
# MSCODE=$$


tr_h1 "wov-init-ms Tests"
tr_comment "NOTE: Expects test1 project to exist, created by test001_init.sh"

{
  tr_section 'prep'

  tr_comment "Using MSCode '${MSCODE}'"
  tr_dir "${TESTDIR}/${TEST}"
  tr_run "remove files" "rm wovtools/k8s/${TEST}${MSCODE}.yaml.wov ; rm wovtools/k8s/${TEST}${MSCODE}-service.yaml.wov ; rm wovtools/k8s/${TEST}-ingress.yaml.wov"

  tr_section '/prep'
}


{
  tr_section 'buildmicroservice'

  tr_test "make the repo only" \
    "wov-init-ms -v --repo-entry aws ${MSCODE} > /dev/null ; echo $?"  0 1 0
  tr_test "test repo exists" \
    "aws ecr describe-repositories --repository-names '${TEST}/${TEST}${MSCODE}' > /dev/null ; echo $?" 0 1 0


  tr_test "make the k8s" \
    ">&2 wov-init-ms -v --k8s ${MSCODE}; echo $?"  0 1 0
  tr_test "dir exists" "[ -d wovtools/k8s ] && echo 0 || echo 1"  0 1 0 
  tr_test "k8s for service exists" "[ -f 'wovtools/k8s/${TEST}${MSCODE}-service.yaml.wov' ] && echo 0 || echo 1"  0 1 0 
  tr_test "k8s for ms exists"      "[ -f 'wovtools/k8s/${TEST}${MSCODE}.yaml.wov' ] && echo 0 || echo 1"  0 1 0 
  tr_test "k8s for ingress exists" "[ -f 'wovtools/k8s/${TEST}-ingress.yaml.wov' ] && echo 0 || echo 1"  0 1 0 
  tr_test "ingress has this ms"    "grep '${TEST}${MSCODE}' wovtools/k8s/${TEST}-ingress.yaml.wov > /dev/null ; echo $?" 0 1 0 


  tr_test "make the recipe" \
    ">&2 wov-init-ms -v --recipe ${MSCODE}; echo $?"  0 1 0
  tr_test "recipe exists" "[ -f 'wovtools/msrecipes/${MSCODE}' ] && echo 0 || echo 1"  0 1 0 


  tr_test "make the ms" \
    ">&2 wov-init-ms -v --ms ${MSCODE}; echo $?"  0 1 0
  tr_test "dir exists" "[ -d ${TEST}${MSCODE}/src ] && echo 0 || echo 1"  0 1 0 
  tr_test "config file exists" "[ -f ${TEST}${MSCODE}/src/${TEST}${MSCODE}config.sh ] && echo 0 || echo 1" 0 1 0 
  tr_test "wov-env --cm works " "wov-env --cm ${TEST}${MSCODE} > /dev/null && echo 1" 0 1 1
  tr_test "wov-env --var port" "wov-env --var WOV_${TEST}${MSCODE}_port" 0 1 "75643"

  # cleanup
  tr_run "rm -Rf ${TEST}${MSCODE}"

  tr_test "make the ms of type nodejs" \
    ">&2 wov-init-ms -v --ms-type nodejs --ms ${MSCODE}; echo $?"  0 1 0
  tr_test "dir exists" "[ -d ${TEST}${MSCODE}/src ] && echo 0 || echo 1"  0 1 0 
  tr_test "package file exists" "[ -f ${TEST}${MSCODE}/package.json ] && echo 0 || echo 1" 0 1 0 
  tr_test "config file exists" "[ -f ${TEST}${MSCODE}/src/index.js ] && echo 0 || echo 1" 0 1 0 
  tr_test "config file exists" "[ -f ${TEST}${MSCODE}/src/${TEST}${MSCODE}config.sh ] && echo 0 || echo 1" 0 1 0 
  tr_test "wov-env --cm works" "wov-env --cm ${TEST}${MSCODE} > /dev/null && echo 1" 0 1 1
  tr_test "wov-env --var port" "wov-env --var WOV_${TEST}${MSCODE}_port" 0 1 "75643"

  # cleanup
  tr_run "rm -Rf ${TEST}${MSCODE}"

  tr_test "make the ms of type nodejs" \
    ">&2 wov-init-ms -v --ms-type woveonservice --ms ${MSCODE}; echo $?"  0 1 0
  tr_test "dir exists" "[ -d ${TEST}${MSCODE}/src ] && echo 0 || echo 1"  0 1 0 
  tr_test "package file exists" "[ -f ${TEST}${MSCODE}/package.json ] && echo 0 || echo 1" 0 1 0 
  tr_test "config file exists" "[ -f ${TEST}${MSCODE}/src/index.js ] && echo 0 || echo 1" 0 1 0 
  tr_test "config file exists" "[ -f ${TEST}${MSCODE}/src/${TEST}${MSCODE}config.js ] && echo 0 || echo 1" 0 1 0 
  tr_test "wov-env --cm works" "wov-env --cm ${TEST}${MSCODE} > /dev/null && echo 1" 0 1 1
  tr_test "wov-env --var port" "wov-env --var WOV_${TEST}${MSCODE}_port" 0 1 "75643"



  tr_section '/buildmicroservice'
}

{
  tr_section "buildsinglems"
  tr_comment "TODO"
  tr_section "/buildsinglems"
}
