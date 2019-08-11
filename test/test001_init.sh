#!/usr/bin/env bash
. /usr/local/bin/wtrunner


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
  rm -Rf "${TESTREPO}/${TEST}_db.git"

  tr_section '/clean-proj'
}

{
  tr_section 'mk-proj'
  tr_comment "${0} : Create a project and test env"

  # make dirs
  mkdir -p "${TESTDIR}/${TEST}"
  mkdir -p "${TESTREPO}/${TEST}.git"
  mkdir -p "${TESTREPO}/${TEST}_db.git"

  # init git
  cd "${TESTREPO}/${TEST}.git" ; git init --bare
  cd "${TESTREPO}/${TEST}_db.git" ; git init --bare


  # add to wovtools/myconfig.json
  tr_dir "${TESTDIR}/${TEST}"
#  wov-init 
#  exit 1
  tr_comment '...starting wov-init'
  wov-init <<STDIN
test1
${TESTREPO}/${TEST}.git
john doe
jd@example.com
${TESTREPO}/${TEST}_db.git
Test 1

A description.



STDIN
exit 1

#/Users/cwingrav/code/woveon/src/wovtools/test/testrepo/test1.git
#/Users/cwingrav/code/woveon/src/wovtools/test/testrepo/test1_db.git


  rm -Rf ${TESTREPO}/${TEST}x
  wov-init-ms ${TEST}x

  tr_test_skip "git checkin"

  tr_section '/mk-proj'
}

