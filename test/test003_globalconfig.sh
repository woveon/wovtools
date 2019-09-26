#!/usr/bin/env bash

. /usr/local/bin/wtrunner

export PATH=$PATH:/usr/local/bin/wovlib
. wov-env-logging
. wov-init-common
. wov-env-common
WOV_DEBUGMODE=1

GWOVTOOLSBAK="${HOME}/.wovtools.`date +%s`"

function finish()
{
  if [ -e "${HOME}/.wovtools" ]; then cp ~/.wovtools ~/.wovtools.lasttestrun; fi
  if [ -e "${GWOVTOOLSBAK}" ]; then mv "${GWOVTOOLSBAK}" ~/.wovtools ; fi
}
trap finish EXIT

#tr_tests_off

tr_h1 "Global .wovtools Tests"

tr_comment "backing up ~/.wovtools"
if [ -e ~/.wovtools ]; then mv ~/.wovtools "${GWOVTOOLSBAK}"; fi

{
  tr_section "Global-Config-Testing"

  tr_comment  "Run iGlobalConfig_CraeteIfNotExists"
  mkdir -p -m 700 /tmp/.wovtools_sea
  mkdir -p -m 700 /tmp/.wovtools_dba
  mkdir -p -m 700 /tmp/.wovtools_dsa
  iGlobalConfig_CreateIfNotExists <<EOF
n
uc
n
/tmp/.wovtools_sea
n
/tmp/.wovtools_dba
n
/tmp/.wovtools_dsa
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

  tr_test "should exist" "[ -e ~/.wovtools ] && echo 'true'" 0 1 'true' 
  tr_test "secrets archives should exist" "[ -e ~/.wovtools_sea ] && echo '1'" 0 1 '1'
  tr_test "DB archives should exist" "[ -e ~/.wovtools_dba ] && echo '1'" 0 1 '1'
  tr_test "DS archives should exist" "[ -e ~/.wovtools_dsa ] && echo '1'" 0 1 '1'
  tr_test "test .me" "[ `jq -r .me ~/.wovtools` == 'uc' ] && echo 1" 0 1 '1' 
  tr_test "test .archives.k8s K8S"      "[ `jq -r .archives.k8s ~/.wovtools` == 'K8S' ] && echo 1" 0 1 '1'
  tr_test "test .archives.container CA" "[ `jq -r .archives.container ~/.wovtools` == 'CA' ] && echo 1" 0 1 '1'
  tr_test "test .archives.coderepo CR"  "[ `jq -r .archives.coderepo ~/.wovtools` == 'CR' ] && echo 1" 0 1 '1'
  tr_test "sea" "[ `jq -r .local.searchives.dir ~/.wovtools` == '/tmp/.wovtools_sea' ] && echo 1" 0 1 '1'
  tr_test "dba" "[ `jq -r .local.dbarchives.dir ~/.wovtools` == '/tmp/.wovtools_dba' ] && echo 1" 0 1 '1'
  tr_test "dsa" "[ `jq -r .local.dsarchives.dir ~/.wovtools` == '/tmp/.wovtools_dsa' ] && echo 1" 0 1 '1'

  # cat ~/.wovtools

  tr_test "Validate ~/.wovtools" "iGlobalConfig_Validate && echo 1" 0 1 '1'

  tr_comment "iGlobalConfig_ReadIn" 
  iGlobalConfig_ReadIn
  tr_test "read in variables from global config" "iGlobalConfig_ReadIn && echo 1" 0 1 '1' 
  tr_test "WOV_ME"                  'echo "${WOV_ME}"' 0 1 'uc' 
  tr_test "WOV_ARCHIVESK8S"         'echo "${WOV_ARCHIVESK8S}"' 0 1 'K8S'
  tr_test "WOV_ARCHIVESCONTAINER"         'echo "${WOV_ARCHIVESCONTAINER}"' 0 1 'CA'
  tr_test "WOV_ARCHIVESCODEREPO"         'echo "${WOV_ARCHIVESCODEREPO}"' 0 1 'CR'
  tr_test "WOV_SEADIR"         'echo "${WOV_SEADIR}"' 0 1 '/tmp/.wovtools_sea'
  tr_test "WOV_DBADIR"         'echo "${WOV_DBADIR}"' 0 1 '/tmp/.wovtools_dba'
  tr_test "WOV_DSADIR"         'echo "${WOV_DSADIR}"' 0 1 '/tmp/.wovtools_dsa'





  tr_section "/Global-Config-Testing"
}

tr_tests_on
{
  tr_section "wov-env-common-tests"


  tr_test "Project Repo Name : Normal Call" \
    'doGetProjectRepoName "PROJECTNAME"' 1 1 'CR/UNKNOWN'
  tr_test "Project Repo Name : Normal Call with User Provided repo ext" \
    'doGetProjectRepoName "PROJECTNAME" "EXT"' 0 1 'CR/EXT'

  tr_comment "add to ~/.wovtools the .projects.PROJECTNAME.[dir|repo|repoext]"
  cat ~/.wovtools | jq -r '.projects.PROJECTNAME={dir : "DIR", repo : "REPO", repobase: "REPOBASE"}' > ~/.wovtools.1 && mv ~/.wovtools.1 ~/.wovtools

  tr_test "Project Repo Name : Master: User Provided" \
    'doGetProjectRepoName "PROJECTNAME" "USERPROVIDED" "MSREPO" "MSREPOBASE"' 0 1 'MSREPOBASE/USERPROVIDED'
  tr_test "Project Repo Name : Master: Default" \
    'doGetProjectRepoName "PROJECTNAME" "" "MSREPO" "MSREPOBASE"' 0 1 'MSREPOBASE/MSREPO'
  tr_test "Project Repo Name : Master: Read from WovTools" \
    'doGetProjectRepoName "PROJECTNAME" "USERPROVIDED" "" ""' 0 1 'REPOBASE/USERPROVIDED'
  tr_test "Project Repo Name : Master: Read from WovTools even though some data passed in" \
    'doGetProjectRepoName "PROJECTNAME" "" "MSREPO" ""' 0 1 'REPOBASE/REPO'

  tr_test "Project Repo Name : Normal Call" \
    'doGetProjectRepoName "PROJECTNAME"' 0 1 'REPOBASE/REPO'
  tr_test "Project Repo Name : Normal Call with User Provided repo ext" \
    'doGetProjectRepoName "PROJECTNAME" "EXT"' 0 1 'REPOBASE/EXT'


  tr_section "/wov-env-common-tests"
}

tr_results
