#!/usr/bin/env bash
. /usr/local/bin/wtrunner


WOV_DEBUGMODE=1
DOECHO=2
TESTDIR=`pwd`
MASTER=$(basename ${TESTDIR})
TEST=test1
PROJ="${TEST}"
LADIR="${TESTDIR}/${MASTER}localarchives"
TESTREPODIR="${TESTDIR}/testremoterepo"
mkdir -p "${TESTREPODIR}"
PROJDIR="${TESTDIR}/${TEST}"
ME=$(cat ${HOME}/.wovtools | jq -r '.me')
PID=$$


tr_h1 "Make Test Repo"

#tr_tests_off
if [ $_tr_testson -eq 1 ]; then
  tr_section 'clean-proj'

  # Remove old dirs and git test git repo
  rm -Rf "${TESTDIR}/${PROJ}"
  rm -Rf ${LADIR}/*archive
  rm -Rf "${TESTREPODIR}/${MASTER}"           # Project repo

  jq -r ".local.searchives.dir" "${HOME}/.wovtools"

  tr_section '/clean-proj'
fi



if [ $_tr_testson -eq 1 ]; then
  tr_section 'mk-proj'
  tr_comment "${0} : Create a project and test env"

  # make dirs for "Remote" Git Repositories
  mkdir -p "${TESTDIR}/${PROJ}"
  mkdir -p "${TESTREPODIR}/${MASTER}/${PROJ}.git"
  mkdir -p "${TESTREPODIR}/${MASTER}/sea/${ME}.git"
  mkdir -p "${TESTREPODIR}/${MASTER}/${PROJ}_dba.git"
  mkdir -p "${TESTREPODIR}/${MASTER}/dsa.git"

  # init "Remote" Git Repositories
  git -C "${TESTREPODIR}/${MASTER}/${PROJ}.git" init --bare
  git -C "${TESTREPODIR}/${MASTER}/sea/${ME}.git" init --bare
  git -C "${TESTREPODIR}/${MASTER}/${PROJ}_dba.git" init --bare
  git -C "${TESTREPODIR}/${MASTER}/dsa.git" init --bare

  # Make local archives for testing
  mkdir -p -m 700 "${LADIR}/searchive/${MASTER}_sea"          # per Master Project Person, but only one person so single directory
  mkdir -p -m 700 "${LADIR}/dbarchive/${MASTER}/${PROJ}_dba"  # per Master Project Team Project, and will create a local repo as needed
  mkdir -p -m 700 "${LADIR}/dsarchive/${MASTER}_dsa"          # per Master Project

  # add to wovtools/myconfig.json
  tr_dir "${TESTDIR}/${PROJ}"

#  wov-init -vv --debugmode \
#              --local-archive-default "${LADIR}"  \
#              --proj-coderepo-default "${TESTREPODIR}" \
#              --cluster-force-build \
#              --cluster-name "wov-aws-va-grape" \
#              --cluster-hostedzone "Z1NR42SJ9ZADVC" \
#              --wovdb-question 0
#exit 1
  tr_comment '...starting wov-init'
  tr_vverbose
  tr_test    "start init" \
    "wov-init -vv --debugmode --local-archive-default \"${LADIR}\" "` 
             `"--proj-coderepo-default \"${TESTREPODIR}\" "` 
             `"--cluster-force-build  "`
             `"--cluster-name \"wov-aws-va-grape\" "`
             `"--cluster-hostedzone \"Z1NR42SJ9ZADVC\" "`
             `"--wovdb-question 0  > /dev/null ; echo $?" 0 1 0  <<EOF


















EOF
  tr_verbose

  tr_section '/mk-proj'
fi

{
  tr_section 'symlinks'


  tr_test "Project Secrets Archive correclty sym linked" \
    "echo ${PID} > \"${LADIR}/searchive/${MASTER}_sea/ii\" ; cat wovtools/secrets/ii" \
    0 1 "${PID}"

  tr_test "Project DB Archives correclty sym linked" \
    "echo ${PID} > \"${LADIR}/dbarchive/${MASTER}/${PROJ}_dba/ii\" ; cat wovtools/db/archive/ii" \
    0 1 "${PID}"

  tr_test "Project DS Archives correclty sym linked" \
    "echo ${PID} > \"${LADIR}/dsarchive/${MASTER}_dsa/ii\" ; cat wovtools/ds/const/ii" \
    0 1 "${PID}"
    
  tr_section '/symlinks'
}

{
  tr_section 'repoconnections'

  tr_test "Project Code to Remote Repo" \
    "git -C "${PROJDIR}" config --get remote.origin.url"  \
    0 1 "${TESTREPODIR}/${MASTER}/${PROJ}"

  tr_test "Local Archive Secrets to Remote Repo" \
    "git -C "${LADIR}/searchive/${MASTER}_sea" config --get remote.origin.url"  \
    0 1 "${TESTREPODIR}/${MASTER}/sea/${ME}.git"

  tr_test "Local Archive DBA to Remote Repo" \
    "git -C "${LADIR}/dbarchive/${MASTER}/${PROJ}_dba" config --get remote.origin.url"  \
    0 1 "${TESTREPODIR}/${MASTER}/${PROJ}_dba.git"

  tr_test "Local Archive DSA to Remote Repo" \
    "git -C "${LADIR}/dsarchive/${MASTER}_dsa" config --get remote.origin.url"  \
    0 1 "${TESTREPODIR}/${MASTER}/dsa.git"

  tr_section '/repoconnections'
}

{
  tr_section 'gitcommits'
  tr_test "git commit" "git commit -a -m 'after init'" 0 -1
  tr_test "git push"   "git push" 0 -1
  tr_section '/gitcommits'
}


#tr_tests_on
{
  tr_section 'wov-env'

  tr_dir "${TESTDIR}/${PROJ}"

  tr_test "test wov-env runs" "wov-env --envs > /dev/null ; echo $?" 0 1 0

  tr_section '/wov-env'
}


tr_popdir
tr_results
