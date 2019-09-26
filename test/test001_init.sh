#!/usr/bin/env bash
. /usr/local/bin/wtrunner


WOV_DEBUGMODE=1
DOECHO=2
TEST=test1
tr_h1 "Make Test Repo"
TESTDIR=`pwd`
TESTREPO="${TESTDIR}/testrepo"
mkdir -p "${TESTREPO}"
PROJDIR="${TESTDIR}/${TEST}"

{
  tr_section 'clean-proj'

  # Remove old dirs and git test git repo
  rm -Rf "${TESTDIR}/${TEST}"
  rm -Rf "${TESTREPO}/${TEST}.git"
  rm -Rf "${TESTREPO}/${TEST}_secrets.git"
  rm -Rf "${TESTREPO}/${TEST}_dba.git"
  rm -Rf "${TESTREPO}/${TEST}_dsa.git"

  tr_section '/clean-proj'
}

{
  tr_section 'mk-proj'
  tr_comment "${0} : Create a project and test env"

  # make dirs
  mkdir -p "${TESTDIR}/${TEST}"
  mkdir -p "${TESTREPO}/${TEST}.git"
  mkdir -p "${TESTREPO}/${TEST}_secrets.git"
  mkdir -p "${TESTREPO}/${TEST}_dba.git"
  mkdir -p "${TESTREPO}/${TEST}_dsa.git"

  # init "remote" git repositories
  git -C "${TESTREPO}/${TEST}.git" init --bare
  git -C "${TESTREPO}/${TEST}_secrets.git" init --bare
  git -C "${TESTREPO}/${TEST}_dba.git" init --bare
  git -C "${TESTREPO}/${TEST}_dbs.git" init --bare

  # add to wovtools/myconfig.json
  tr_dir "${TESTDIR}/${TEST}"
wov-init  -v
exit 1
  tr_comment '...starting wov-init'
  wov-init <<EOF







n
/Users/cwingrav/code/woveon/src/wovtools/test/testrepo/test1
Y


y
Y
EOF
 exit 1


  wov-init <<STDIN
Y
${TESTREPO}/${TEST}.git
john doe
jd@example.com
${TESTREPO}/${TEST}_dba.git
Test 1

A description.



STDIN
  if [ $? != 0 ]; then
    exit 1
  fi
# PROJECT
# Remote git repository
# User name
# email
# db test repo
# title




  tr_section '/mk-proj'
}



{
  tr_section 'mk-ms'

  rm -Rf ${TESTREPO}/${TEST}X
  wov-init-ms ${TEST}X

  tr_test_skip "git checkin"
  git add test1X wovtools
  git commit -a -m 'first commit'
  git push

  tr_section '/mk-ms'
}

tr_popdir
tr_results
