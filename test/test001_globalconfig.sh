#!/usr/bin/env bash

. /usr/local/bin/wtrunner
FOLD=`tput cols`
WOV_DEBUGMODE=1

. test_common.sh

export PATH=$PATH:/usr/local/bin/wovlib
ISWOVPROJECT=0
. wov-env-loader
. wov-env-logging
. wov-init-common
. wov-env-common

#GWOVTOOLSBAK="${WOVCONFIGF}.`date +%s`"
#function finish()
#{
#  if [ -e "${WOVCONFIGF}" ]; then cp ${WOVCONFIGF} ${WOVCONFIGF}.lasttestrun; fi
#  if [ -e "${GWOVTOOLSBAK}" ]; then mv "${GWOVTOOLSBAK}" "${WOVCONFIGF} ; fi
#}
#trap finish EXIT


#tr_tests_off

tr_h1 "Global WOVCONFIGF Tests"

tr_protectfile  "${WOVCONFIGF}" del
#tr_protectdir  "${WOVCONFIGDIR}" del

{
  tr_section "Global-Config-Testing"

  tr_comment  "Run iGlobalConfig_CreateIfNotExists"
#  mkdir -p -m 700 ${LADIR}/searchive
#  mkdir -p -m 700 ${LADIR}/dsarchive
#  mkdir -p -m 700 ${LADIR}/dbarchive
#  tr_h1 "LADIR: ${LADIR}"
  iGlobalConfig_CreateIfNotExists '/tmp/foo' <<EOF
n
${TESTME}
n
K8S
Y
n
CA
Y
n
CR
Y
EOF


#  tr_test "secrets archives should exist" "[ -e ${LADIR}/searchive ] && echo '1'" 0 1 '1'
#  tr_test "DB archives should exist"      "[ -e ${LADIR}/dbarchive ] && echo '1'" 0 1 '1'
#  tr_test "DS archives should exist"      "[ -e ${LADIR}/dsarchive ] && echo '1'" 0 1 '1'
  tr_test "test .me" "[ `jq -r .me "${WOVCONFIGF}"` == '${TESTME}' ] && echo 1" 0 1 '1' 
  tr_test "test .archives.k8s K8S"      "[ `jq -r .archives.k8s "${WOVCONFIGF}"` == 'K8S' ] && echo 1" 0 1 '1'
  tr_test "test .archives.container CA" "[ `jq -r .archives.container "${WOVCONFIGF}"` == 'CA' ] && echo 1" 0 1 '1'
  tr_test "test .archives.coderepo CR"  "[ `jq -r .archives.coderepo  "${WOVCONFIGF}"` == 'CR' ] && echo 1" 0 1 '1'
  tr_test "local archive base"          "[ `jq -r .archives.localbase "${WOVCONFIGF}"` == '/tmp/foo' ] && echo 1" 0 1 '1'

  # cat ${WOVCONFIGF}

  tr_test "Validate WOVCONFIGF" "iGlobalConfig_Validate && echo 1" 0 1 '1'

  tr_comment "iGlobalConfig_ReadIn" 
  iGlobalConfig_ReadIn
  tr_test "read in variables from global config" "iGlobalConfig_ReadIn && echo 1" 0 1 '1' 
  tr_test "WOV_ME"               'echo "${WOV_ME}"' 0 1 "${TESTME}"
  tr_test "WOV_K8SARCHIVE"       'echo "${WOV_K8SARCHIVE}"' 0 1 'K8S'
  tr_test "WOV_CONTAINERARCHIVE" 'echo "${WOV_CONTAINERARCHIVE}"' 0 1 'CA'
  tr_test "WOV_CODEREPOARCHIVE"  'echo "${WOV_CODEREPOARCHIVE}"' 0 1 'CR'
  tr_test "WOV_LOCALARCHIVEBASE" 'echo "${WOV_LOCALARCHIVEBASE}"' 0 1 "/tmp/foo"
  # tr_test "WOV_SEADIR"           'echo "${WOV_SEADIR}"' 0 1 "${LADIR}/searchive"
  # tr_test "WOV_DBADIR"           'echo "${WOV_DBADIR}"' 0 1 "${LADIR}/dbarchive"
  # tr_test "WOV_DSADIR"           'echo "${WOV_DSADIR}"' 0 1 "${LADIR}/dsarchive"

  tr_section "/Global-Config-Testing"
}

tr_tests_on
{
  tr_section "wov-env-common-tests"


  tr_run "WOVCONFIGF now" "cat ${WOVCONFIGF}"

#  tr_test "Project Repo Name : Normal Call" \
#    'doGetProjectRepoName "PROJECTNAME"' 1 1 'CR/UNKNOWN'
#  tr_test "Project Repo Name : Normal Call with User Provided repo ext" \
#    'doGetProjectRepoName "PROJECTNAME" "EXT"' 0 1 'CR/EXT'

  tr_comment "add to WOVCONFIGF the .projects.PROJECTNAME.[dir|repo|repoext]"
  cat "${WOVCONFIGF}" | jq -r '.projects.PROJECTNAME={dir : "DIR", repo : "REPO", repobase: "REPOBASE"}' > "${WOVCONFIGF}.1" && cp "${WOVCONFIGF}.1" "${WOVCONFIGF}" && rm "${WOVCONFIGF}.1"

#  tr_test "Project Repo Name : Master: User Provided" \
#    'doGetProjectRepoName "PROJECTNAME" "USERPROVIDED" "MSREPO" "MSREPOBASE"' 0 1 'MSREPOBASE/USERPROVIDED'
#  tr_test "Project Repo Name : Master: Default" \
#    'doGetProjectRepoName "PROJECTNAME" "" "MSREPO" "MSREPOBASE"' 0 1 'MSREPOBASE/MSREPO'
#  tr_test "Project Repo Name : Master: Read from WovTools" \
#    'doGetProjectRepoName "PROJECTNAME" "USERPROVIDED" "" ""' 0 1 'REPOBASE/USERPROVIDED'
#  tr_test "Project Repo Name : Master: Read from WovTools even though some data passed in" \
#    'doGetProjectRepoName "PROJECTNAME" "" "MSREPO" ""' 0 1 'REPOBASE/REPO'

#  tr_test "Project Repo Name : Normal Call" \
#    'doGetProjectRepoName "PROJECTNAME"' 0 1 'REPOBASE/REPO'
#  tr_test "Project Repo Name : Normal Call with User Provided repo ext" \
#    'doGetProjectRepoName "PROJECTNAME" "EXT"' 0 1 'REPOBASE/EXT'


  tr_section "/wov-env-common-tests"
}

tr_results
