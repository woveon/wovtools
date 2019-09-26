#!/usr/bin/env bash

. /usr/local/bin/wtrunner

export PATH=$PATH:/usr/local/bin/wovlib
ISWOVPROJECT="0"
. wov-env-logging
. wov-init-common
. wov-env-common
WOV_DEBUGMODE=1
DOECHO=2


# Configure a dummy local git repo
DPN="dummyproject"
REPODIR="`pwd`/${DPN}repo"
LADIR="`pwd`/${DPN}localarchives"

FOLD=`tput cols`

tr_h1 "Git Init Tests"

{
  tr_section "inittests"

  WOV_ME='aaa'
  rm -Rf ./${DPN} || exit 1
  mkdir ${DPN} || exit 1
  rm -Rf "${REPODIR}"
  rm -Rf "${LADIR}"
  mkdir -p "${REPODIR}/${DPN}.git"
  mkdir -p "${REPODIR}/${DPN}_secrets.git"
  mkdir -p "${REPODIR}/${DPN}_dba.git"
  mkdir -p "${REPODIR}/${DPN}_dsa.git"
  git -C "${REPODIR}/${DPN}.git" init --bare
  git -C "${REPODIR}/${DPN}_secrets.git" init --bare
  git -C "${REPODIR}/${DPN}_dba.git" init --bare
  git -C "${REPODIR}/${DPN}_dsa.git" init --bare

  tr_dir ./${DPN}
  WOV_BASEDIR=`pwd`

  tr_section "/inittests"
}


{
  tr_section "init"

  tr_test "test init of git in new directory" \
    "iProjGit_InteractiveUpdate '${REPODIR}' '${DPN}' '${WOV_ME}' > /dev/null && printf \"$?\n\${WOV_USERNAME}\"" 0 2 '0' "`id -F`" <<EOF



y
EOF
  tr_test "check branches" "( git branch )" 0 3 "* ${WOV_ME}" "  dev" "  prod"
  tr_test "name check " "git config user.name" 0 1 "`id -F`"

  tr_section "/init"
}


{
  tr_section "init-proj-dir"
 
  tr_test "ensure dirs" "iProjDir_Init ${WOV_BASEDIR} > /dev/null" 0 1 ''
  tr_test "directories" "if [ ! -e ${WOV_BASEDIR}/wovtools ]; then exit 1; fi" 0 1 ''

  tr_section "/init-proj-dir"
}

{
  tr_section "init-proj-local-archives"

  if [ "${LADIR}" == "" ]; then echo "ERROR: LADIR needs to be set"; exit 1; fi

  tr_test "Link project to local Archives, creating local archives as well" \
    "iLocalArchives_LinkLocalArchives \".\" \"${DPN}\" \"${LADIR}/se\" \"${LADIR}/db\" \"${LADIR}/ds\" 'Bob Brown' 'bb@example.com' > /dev/null"  \
    0 1 ''

  tr_comment "test local archive creationg and git repo setup"
  tr_test "se directory test" "[ -e \"${LADIR}/se\"] ; printf $?" 0 1 0
  tr_test "se git test" "git -C '${LADIR}/se/${DPN}' rev-parse --git-dir 2> /dev/null" 0 1 '.git' 
  tr_test "db directory test" "[ -e \"${LADIR}/db\"] ; printf $?" 0 1 0
  tr_test "db git test" "git -C '${LADIR}/db/${DPN}' rev-parse --git-dir 2> /dev/null" 0 1 '.git' 
  tr_test "ds directory test" "[ -e \"${LADIR}/ds\"] ; printf $?" 0 1 0
  tr_test "ds git test" "git -C '${LADIR}/ds/${DPN}' rev-parse --git-dir 2> /dev/null" 0 1 '.git' 

  tr_comment "test links to local repos"

  tr_test "SE: symbolic link to local archives" "[ \"`readlink wovtools/secrets`\" == \"${LADIR}/se/${DPN}\" ] || exit 1" 0 1 ''
  tr_test "DB: symbolic link to local archives" "[ \"`readlink wovtools/db/archive`\" == \"${LADIR}/db/${DPN}\" ] || exit 1" 0 1 ''
  tr_test "DS: symbolic link to local archives" "[ \"`readlink wovtools/ds/const`\" == \"${LADIR}/ds/${DPN}\" ] || exit 1" 0 1 ''


  tr_run "Create mastr project secrets" "iLocalArchives_SEFiles \".\" \"${DPN}\" "mm" \"example.com\" " 
  tr_test "it should exist now" "[ -e \"wovtools/secrets/${DPN}.json\" ] ; printf $?" 0 1 0
  tr_test "it should exist now" "[ -e \"wovtools/secrets/${DPN}_mm.json\" ] ; printf $?" 0 1 0
  tr_run "Create master project db secrets" "iLocalArchives_SEDBFiles \".\" \"${DPN}\" "mm" "
  tr_test "it should exist now" "[ -e \"wovtools/secrets/${DPN}db.json\" ] ; printf $?" 0 1 0
  tr_test "it should exist now" "[ -e \"wovtools/secrets/${DPN}db_mm.json\" ] ; printf $?" 0 1 0
  # TODO - json tests and validation


  tr_comment "link project local archives to remote repos"
  tr_test "Set up remote repos" "iLocalArchives_InteractiveSetRemoteRepos \"${WOV_BASEDIR}\" > /dev/null ; printf $?" 0 1 0  <<EOF
Y
Y
Y
EOF
  tr_test "check remote repos" "[ \"`git -C ./wovtools/ds/const remote -v`\" == \"${REPODIR}/${DPN}_secrets.git\" ] ; printf $?" 0 1 0
  #tr_vverbose
  #tr_verbose

  tr_section "/init-proj-local-archives"
}


tr_results
