#!/usr/bin/env bash
. /usr/local/bin/wtrunner


#WOV_DEBUGMODE=1
#DOECHO=2

tr_h1 "Test ${0}"
. test_common.sh
tcUseTestingContext


#TESTDIR=`pwd`
#MASTER=$(basename ${TESTDIR})
#TEST=test1
#PROJ="${TEST}"
#LADIR="${TESTDIR}/${MASTER}localarchives"
#TESTREPODIR="${TESTDIR}/testremoterepo"
#mkdir -p "${TESTREPODIR}"
#PROJDIR="${TESTDIR}/${TEST}"
#ME=$(cat ${HOME}/.wovtools | jq -r '.me')
PID=$$
  # --- used as a unique number below


#tr_protectfile "${HOME}/.wovtools"

#if [ "${KOPS_CLUSTER_NAME}" == "" ]; then
#  tr_comment "KOPS_CLUSTER_NAME is not set. See your available clusters with 'kops get clusters'."
#  exit 1
#else
#  USEHOSTEDZONE="Z1NR42SJ9ZADVC"
#  KOPSSPLIT=(${KOPS_CLUSTER_NAME//./ })
#  if [ ${#KOPSSPLIT[@]} -ne 3 ]; then echo "KOPS_CLUSTER_NAME should be named CLUSTER.DOMAIN, with CLUSTER as per WovTools naming."; fi
#  USECLUSTER="${KOPSSPLIT[0]}"
#  USEDOMAIN="${KOPSSPLIT[1]}.${KOPSSPLIT[2]}"
#fi
#
#tr_h3      "Assuming:"
#tr_comment "         Cluster : ${USECLUSTER}"
#tr_comment "         Domain  : ${USEDOMAIN}"
#tr_comment " AWS Hosted Zone : ${USEHOSTEDZONE}"


tr_h1 "Make Test Repo"

#tr_tests_off
if [ $_tr_testson -eq 1 ]; then
  tr_section 'clean-proj'

  # Remove old dirs and git test git repo
  rm -Rf "${TESTDIR}/${PROJ}"
  rm -Rf ${LADIR}/*archive
  rm -Rf ${TESTREPODIR}/${MASTER}_*.git

  jq -r ".local.searchives.dir" "${HOME}/.wovtools"
  cat "${HOME}/.wovtools" | jq -r "del(.projects.${PROJ})"  > ~/.wovtools.$$
  mv ~/.wovtools.$$ ~/.wovtools

#  tr_test "set current kubernetes context just in case" "kubectl config use-context ${USECLUSTER}-${PROJ}-${TESTME}" 0 -1

  tr_section '/clean-proj'
fi



if [ $_tr_testson -eq 1 ]; then
  tr_section 'mk-proj'
  tr_comment "${0} : Create a project and test env"

  # make dirs for "Remote" Git Repositories
  mkdir -p "${TESTDIR}/${PROJ}"
  mkdir -p "${TESTREPODIR}/${MASTER}_${PROJ}.git"
  mkdir -p "${TESTREPODIR}/${MASTER}_sea_${TESTME}.git"
  mkdir -p "${TESTREPODIR}/${MASTER}_${PROJ}_dba.git"
  mkdir -p "${TESTREPODIR}/${MASTER}_dsa.git"

  # init "Remote" Git Repositories
  git -C "${TESTREPODIR}/${MASTER}_${PROJ}.git" init --bare
  git -C "${TESTREPODIR}/${MASTER}_sea_${TESTME}.git" init --bare
  git -C "${TESTREPODIR}/${MASTER}_${PROJ}_dba.git" init --bare
  git -C "${TESTREPODIR}/${MASTER}_dsa.git" init --bare

  # Make local archives for testing
  mkdir -p -m 700 "${LADIR}/searchive/${MASTER}_sea"          # per Master Project Person, but only one person so single directory
  mkdir -p -m 700 "${LADIR}/dbarchive/${MASTER}_${PROJ}_dba"  # per Master Project Team Project, and will create a local repo as needed
  mkdir -p -m 700 "${LADIR}/dsarchive/${MASTER}_dsa"          # per Master Project

  # add to wovtools/myconfig.json
  tr_dir "${TESTDIR}/${PROJ}"

#  wov-init -vv --debugmode \
#              --local-archive-base "${LADIR}"  \
#              --proj-coderepo-default "${TESTREPODIR}" \
#              --cluster-force-build \
#              --cluster-name "${USECLUSTER}" \
#              --cluster-domain "${USEDOMAIN}" \
#              --cluster-hostedzone "${USEHOSTEDZONE}" \
#              --usercode "${TESTME}" \
#              --wovdb-question 0
#exit 1

  tr_comment '...starting wov-init'
  tr_vverbose
  tr_test    "start init" \
    "wov-init -vv --debugmode "`
             `"--local-archive-base \"${LADIR}\" "` 
             `"--proj-coderepo-default \"${TESTREPODIR}\" "` 
             `"--cluster-force-build  "`
             `"--cluster-name \"${USECLUSTER}\" "`
             `"--cluster-domain \"${USEDOMAIN}\" "`
             `"--cluster-hostedzone \"${USEHOSTEDZONE}\" "`
             `"--usercode \"${TESTME}\" "`
             `"--wovdb-question 0 > /dev/null ; echo $? " 0 1 0  <<EOF
Y
Y
Y
Y
Y
Y
Y
Y
Y
Y


y
Y
Y
Y
Y
Y
EOF
  tr_verbose

  tr_section '/mk-proj'
fi

{
  tr_section 'symlinktest'


  tr_test "Project Secrets Archive correctly sym linked" \
    "echo ${PID} > \"${LADIR}/searchive/${MASTER}_sea/ii\" ; cat wovtools/secrets/ii" \
    0 1 "${PID}"

  tr_test "Project DB Archives correctly sym linked" \
    "echo ${PID} > \"${LADIR}/dbarchive/${MASTER}_${PROJ}_dba/ii\" ; cat wovtools/db/archive/ii" \
    0 1 "${PID}"

  tr_test "Project DS Archives correctly sym linked" \
    "echo ${PID} > \"${LADIR}/dsarchive/${MASTER}_dsa/ii\" ; cat wovtools/ds/const/ii" \
    0 1 "${PID}"
    
  tr_section '/symlinktest'
}

{
  tr_section 'repoconnections'

  tr_test "Project Code to Remote Repo" \
    "git -C "${PROJDIR}" config --get remote.origin.url"  \
    0 1 "${TESTREPODIR}/${MASTER}_${PROJ}"

  tr_test "Local Archive Secrets to Remote Repo" \
    "git -C \"${LADIR}/searchive/${MASTER}_sea\" config --get remote.origin.url"  \
    0 1 "${TESTREPODIR}/${MASTER}_sea_${TESTME}"

  tr_test "Local Archive DBA to Remote Repo" \
    "git -C \"${LADIR}/dbarchive/${MASTER}_${PROJ}_dba\" config --get remote.origin.url"  \
    0 1 "${TESTREPODIR}/${MASTER}_${PROJ}_dba"

  tr_test "Local Archive DSA to Remote Repo" \
    "git -C \"${LADIR}/dsarchive/${MASTER}_dsa\" config --get remote.origin.url"  \
    0 1 "${TESTREPODIR}/${MASTER}_dsa"

  tr_section '/repoconnections'
}

{
  tr_section 'testglobal'

  FF="$(jq -r ".projects.${PROJ}" ~/.wovtools)" ; Re=$?
  if [ $Re -ne 0 ]; then l_error "Failed to parse ~/.wovtools file for '.projects.${PROJ}'"; exit 1; fi
  if [ "${FF}" == "null" ]; then l_error "Failed to find '.projects.${PROJ}' entry in ~/.wovtools"; exit 1; fi
  tr_section '/testglobal'
}

{
  tr_section 'gitcommits'

  tr_h3 "Code Repo Git"
  tr_test "git commit" "git commit -a -m 'after init'" 0 -1
  tr_test "git push"   "git push" 0 -1

  tr_h3 "Secrets Repo Git"
  tr_test "add files" "git -C wovtools/secrets add cluster_mymanaged.json ii repositories.json test.json test_${TESTME}.json test_dev.json test_prod.json" 0 -1
  tr_test "git commit" "git -C wovtools/secrets commit -a -m 'after init'" 0 -1
  tr_test "git push"   "git -C wovtools/secrets push"                      0 -1

  tr_h3 "DataBase Repo Git"
  tr_test "add files"  "git -C wovtools/db/archive add ii" 0 -1
  tr_test "git commit" "git -C wovtools/db/archive commit -a -m 'after init'" 0 -1
  tr_test "git push"   "git -C wovtools/db/archive push"                      0 -1

  tr_h3 "DataSet Repo Git"
  tr_test "add files"  "git -C wovtools/ds/const add ii" 0 -1
  tr_test "git commit" "git -C wovtools/ds/const commit -a -m 'after init'" 0 -1
  tr_test "git push"   "git -C wovtools/ds/const push"                      0 -1

  tr_section '/gitcommits'
}


#tr_tests_on
{
  tr_section 'wov-env'

  tr_dir "${TESTDIR}/${PROJ}"

  tr_test "test wov-env runs" "wov-env --envs > /dev/null ; echo $?" 0 1 0

  tr_section '/wov-env'
}

{
  tr_section "checkins"
  git -C wovtools/secrets add "test.json"
  git -C wovtools/secrets commit -a -m "test011 secrets"
  git -C wovtools/secrets push
  tr_section "/checkins"
}


tr_popdir
tr_results
