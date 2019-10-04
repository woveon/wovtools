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


tr_h1 "Make Test Repo"

#tr_tests_off
if [ $_tr_testson -eq 1 ]; then
  tr_section 'clean-proj'

  # Remove old dirs and git test git repo
  rm -Rf "${TESTDIR}/${TEST}"
  rm -Rf "${LADIR}"
  rm -Rf "${TESTREPO}/test_${TEST}.git"
  rm -Rf "${TESTREPO}/test_${TEST}_secrets.git"
  rm -Rf "${TESTREPO}/test_${TEST}_dba.git"
  rm -Rf "${TESTREPO}/test_${TEST}_dsa.git"

  jq -r ".local.searchives.dir" "${HOME}/.wovtools"

  tr_section '/clean-proj'
fi



if [ $_tr_testson -eq 1 ]; then
  tr_section 'mk-proj'
  tr_comment "${0} : Create a project and test env"

  # make dirs
  mkdir -p "${TESTDIR}/${TEST}"
  mkdir -p "${TESTREPO}/test_${TEST}.git"
  mkdir -p "${TESTREPO}/test_${TEST}_secrets.git"
  mkdir -p "${TESTREPO}/test_${TEST}_dba.git"
  mkdir -p "${TESTREPO}/test_${TEST}_dsa.git"

  # init "remote" git repositories
  git -C "${TESTREPO}/test_${TEST}.git" init --bare
  git -C "${TESTREPO}/test_${TEST}_secrets.git" init --bare
  git -C "${TESTREPO}/test_${TEST}_dba.git" init --bare
  git -C "${TESTREPO}/test_${TEST}_dsa.git" init --bare

  # Make local archives for testing
  mkdir -p -m 700 "${LADIR}/secrets"
  mkdir -p -m 700 "${LADIR}/dbarchives"
  mkdir -p -m 700 "${LADIR}/dsarchives"

  # add to wovtools/myconfig.json
  tr_dir "${TESTDIR}/${TEST}"

#  wov-init -v --local-archive-default "${LADIR}" -v \
#              --proj-coderepo-default "${TESTREPO}" \
#              --cluster-force-build \
#              --cluster-name "wov-aws-va-grape" \
#              --cluster-hostedzone "Z1NR42SJ9ZADVC" \
#              --wovdb-question 0
#exit 1
  tr_comment '...starting wov-init'
  tr_vverbose
  tr_test    "start init" \
    "wov-init -vv --debugmode --local-archive-default \"${LADIR}\" "` 
             `"--proj-coderepo-default \"${TESTREPO}\" "` 
             `"--cluster-force-build  "`
             `"--cluster-name \"wov-aws-va-grape\" "`
             `"--cluster-hostedzone \"Z1NR42SJ9ZADVC\" "`
             `"--wovdb-question 0  > /dev/null ; echo $?" 0 1 0  <<EOF


















EOF
  tr_verbose

  tr_section '/mk-proj'
fi

{
  tr_section 'gitcommits'
  tr_test "git commit" "git commit -a -m 'after init'" 0 -1
  tr_test "git push"   "git push" 0 -1
  tr_section '/gitcommits'
}


#tr_tests_on
{
  tr_section 'wov-env'

  tr_dir "${TESTDIR}/${TEST}"

  tr_test "test wov-env runs" "wov-env --envs > /dev/null ; echo $?" 0 1 0

  tr_section '/wov-env'
}


tr_popdir
tr_results
