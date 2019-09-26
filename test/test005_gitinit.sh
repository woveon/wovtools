#!/usr/bin/env bash

. /usr/local/bin/wtrunner

export PATH=$PATH:/usr/local/bin/wovlib
ISWOVPROJECT="0"
. wov-env-logging
. wov-init-common
. wov-env-common
WOV_DEBUGMODE=1


# Configure a dummy local git repo
DPN="dummyproject"
REPODIR="`pwd`/${DPN}repo"

FOLD=`tput cols`

tr_h1 "Git Init Tests"

{
  tr_section "inittests"

  rm -Rf ./${DPN} || exit 1
  mkdir ${DPN} || exit 1
  rm -Rf "${REPODIR}"
  mkdir -p "${REPODIR}/${DPN}.git"
  mkdir -p "${REPODIR}/${DPN}_secrets.git"
  mkdir -p "${REPODIR}/${DPN}_dba.git"
  git -C "${REPODIR}/${DPN}.git" init --bare
  git -C "${REPODIR}/${DPN}_secrets.git" init --bare
  git -C "${REPODIR}/${DPN}_dba.git" init --bare

  tr_dir ./${DPN}
  WOV_BASEDIR=`pwd`

  tr_section "/inittests"
}


{
  tr_section "init"

  iProjGit_InteractiveUpdate

  tr_section "/init"
}

{
  tr_section "from-readin-values"
 
  iGlobalConfig_ReadIn
  iProjGit_InteractiveUpdate

  tr_section "/from-readin-values"
}


tr_results
