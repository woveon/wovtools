#!/usr/bin/env bash

. /usr/local/bin/wtrunner

export PATH=$PATH:/usr/local/bin/wovlib
ISWOVPROJECT="0"
. wov-env-logging
. wov-init-common
. wov-env-common
WOV_DEBUGMODE=1

DPN="dummyproject"
FOLD=`tput cols`

#tr_tests_off

tr_h1 "Project Tests : wovtools/config.json"
tr_protectfile "${HOME}/.wovtools" "del"

{
  tr_section "create dummy project"

  pwd
  rm -Rf ./${DPN} || exit 1
  mkdir ${DPN} || exit 1
  tr_dir ./${DPN}
  WOV_BASEDIR=`pwd`
  . wov-env-loader 

  tr_section "/create dummy project"
}

if [ `tr_istesting ; echo $?` -eq 1 ]; then
  tr_section "ProjectConfigInit"

#  unset WOV_K8SARCHIVE
#  unset WOV_CONTAINERARCHIVE
#  unset WOV_CODEREPOARCHIVE
  iProjConfig_CreateIfNotExists <<EOF
Y
Y
Y
Y
Y
Y
Y
EOF

  tr_test "should exist" "[ -e ./wovtools/config.json ] && echo 'true'" 0 1 'true'
  tr_test "should be valid json" "iProjConfig_Validate && echo 'true'" 0 1 'true'
  tr_test "test .ver ${WOV_VERSION}"    "[ `jq -r .ver wovtools/config.json` == '${WOV_VERSION}' ] && echo 1" 0 1 '1'
  tr_test "test .project.masterproject" "[ \"`jq -r .project.masterproject wovtools/config.json`\" == 'test' ] && echo 1" 0 1 '1'
  tr_test "test .project.name"          "[ \"`jq -r .project.name wovtools/config.json`\" == 'dummyproject' ] && echo 1" 0 1 '1'
  tr_test "test .project.type"          "[ \"`jq -r .project.type wovtools/config.json`\" == '' ] && echo 1" 0 1 '1'
  tr_test "test .project.title"         "[ \"`jq -r .project.title wovtools/config.json`\" == 'Dummyproject' ] && echo 1" 0 1 '1'
  tr_test "test .project.description"   \
    "[ \"`jq -r .project.description wovtools/config.json`\" == 'A project Dummyproject.' ] && echo 1" 0 1 '1'
  cat wovtools/config.json
  tr_test "test .archives.k8s"          "[ \"`jq -r .archives.k8s wovtools/config.json`\" == '' ] && echo 1" 0 1 '1'
  tr_test "test .archives.container"    "[ \"`jq -r .archives.container wovtools/config.json`\" == '' ] && echo 1" 0 1 '1'
  tr_test "test .archives.coderepo"     "[ \"`jq -r .archives.coderepo wovtools/config.json`\" == '' ] && echo 1" 0 1 '1'

  tr_run "cleanup" "_iProjConfig_Clear"

  tr_section "/ProjectConfigInit"
fi


if [ `tr_istesting ; echo $?` -eq 1 ]; then
  tr_section "ProjectConfigSkipping"

  tr_test "validate existing" "iProjConfig_Validate && echo '1'" 0 1 '1'
  tr_test "should exist since created " "iProjConfig_CreateIfNotExists && echo 1" 0 1 '1'
  tr_test "validate existing" "iProjConfig_Validate && echo '1'" 0 1 '1'

  tr_section "/ProjectConfigSkipping"
fi


if [ `tr_istesting ; echo $?` -eq 1 ]; then
  tr_section "ProjectConfigInitDeltas"

  tr_run "remove Project Config" "rm ${WOV_CONFIGFILE_MAINRAW}"

  #iProjConfig_CreateIfNotExists 
  iProjConfig_CreateIfNotExists <<EOF
n
pp
n
mp
n
project title
Y
n
project description
Y
n
K8s
Y
n
container
Y
n
coderepo
Y
EOF

  tr_test "should exist" "[ -e ./wovtools/config.json ] && echo 'true'" 0 1 'true'
  tr_test "should be valid json" "iProjConfig_Validate && echo 'true'" 0 1 'true'
  tr_test "test .ver ${WOV_VERSION}"      "[ `jq -r .ver wovtools/config.json` == '${WOV_VERSION}' ] && echo 1" 0 1 '1'
  tr_test "test .project.masterproject"   "jq -r .project.masterproject wovtools/config.json" 0 1 'mp'
  tr_test "test .project.name"   "[ \"`jq -r .project.name wovtools/config.json`\" == 'pp' ] && echo 1" 0 1 '1'
  tr_test "test .project.type"   "[ \"`jq -r .project.type wovtools/config.json`\" == '' ] && echo 1" 0 1 '1'
  tr_test "test .project.title"   "[ \"`jq -r .project.title wovtools/config.json`\" == 'project title' ] && echo 1" 0 1 '1'
  tr_test "test .project.description"   "[ \"`jq -r .project.description wovtools/config.json`\" == 'project description' ] && echo 1" 0 1 '1'
  tr_test "test .archives.k8s"   "[ \"`jq -r .archives.k8s wovtools/config.json`\" == '`realpath K8s`' ] && echo 1" 0 1 '1'
  tr_test "test .archives.container"   "[ \"`jq -r .archives.container wovtools/config.json`\" == '`realpath container`' ] && echo 1" 0 1 '1'
  tr_test "test .archives.coderepo"   "[ \"`jq -r .archives.coderepo wovtools/config.json`\" == '`realpath coderepo`' ] && echo 1" 0 1 '1'

  tr_run "cleanup" "_iProjConfig_Clear"
  tr_section "/ProjectConfigInitDeltas"
fi

if [ `tr_istesting ; echo $?` -eq 1 ]; then
  tr_section "ProjectConfigWGlobal"
  tr_comment "This keeps global defaults if already set."

  tr_run "remove Project Config" "rm ${WOV_CONFIGFILE_MAINRAW}"
  iGlobalConfig_ReadIn
  wov_K8SARCHIVE="${WOV_K8SARCHIVE}"
  iProjConfig_CreateIfNotExists <<EOF
n
pp
n
mp
n
project title
Y
n
project description
Y
Y
n
container
Y
n
coderepo
Y
EOF
  tr_test "test .archives.k8s"   "jq -r .archives.k8s wovtools/config.json" 0 1 "${wov_K8SARCHIVE}"
  tr_test "test .archives.container"   "jq -r .archives.container wovtools/config.json" 0 1 "`realpath container`"
  tr_test "test .archives.coderepo"   "jq -r .archives.coderepo wovtools/config.json" 0 1 "`realpath coderepo`"

  tr_run "cleanup" "_iProjConfig_Clear"
  tr_section "/ProjectConfigWGlobal"
fi

tr_tests_on
if [ `tr_istesting ; echo $?` -eq 1 ]; then
  tr_section "naming and repos"

  unset wov_REPO_TYPE wov_REPO_EXT wov_REPO_MSCODE
  tr_test "many passing" 'iProjRepo_Naming MP P P MP ; printf "$?\n${wov_REPO_TYPE}\n${wov_REPO_EXT}\n${wov_REPO_MSCODE}\n"' 0 4 '0' 'many' 'MP/P' ''
  tr_test "many failing dir naming" 'iProjRepo_Naming MP P P1 MP1 ; printf "$?\n${wov_REPO_TYPE}\n${wov_REPO_EXT}\n${wov_REPO_MSCODE}\n"' 0 4 '24' 'many' 'MP/P' ''
  tr_test "many failing dir naming" 'iProjRepo_Naming MP P P MP1 ; printf "$?\n${wov_REPO_TYPE}\n${wov_REPO_EXT}\n${wov_REPO_MSCODE}\n"' 0 4 '8' 'many' 'MP/P' ''
  tr_test "many failing dir naming" 'iProjRepo_Naming MP P P1 MP ; printf "$?\n${wov_REPO_TYPE}\n${wov_REPO_EXT}\n${wov_REPO_MSCODE}\n"' 0 4 '16' 'many' 'MP/P' ''

  mkdir 'src'
  tr_test "single passing" 'iProjRepo_Naming MASTER PROJECT PROJECTmsc PROJECT ; printf "$?\n${wov_REPO_TYPE}\n${wov_REPO_EXT}\n${wov_REPO_MSCODE}\n"' 0 4 '0' 'single' 'MASTER/PROJECT-PROJECTmsc' 'msc'
  tr_test "single failing on dir" 'iProjRepo_Naming MASTER PROJECT PROJECTmsc _PROJECT ; printf "$?\n${wov_REPO_TYPE}\n${wov_REPO_EXT}\n${wov_REPO_MSCODE}\n"' 0 4 '1' 'single' 'MASTER/PROJECT-PROJECTmsc' 'msc'
  tr_test "single failing on dir" 'iProjRepo_Naming MASTER PROJECT _PROJECTmsc _PROJECT ; printf "$?\n${wov_REPO_TYPE}\n${wov_REPO_EXT}\n${wov_REPO_MSCODE}\n"' 0 4 '3' 'single' '' ''
  tr_test "single failing on dir" 'iProjRepo_Naming MASTER PROJECT PROJECmsc PROJECT ; printf "$?\n${wov_REPO_TYPE}\n${wov_REPO_EXT}\n${wov_REPO_MSCODE}\n"' 0 4 '2' 'single' '' ''
  tr_test "single failing on dir" 'iProjRepo_Naming MASTER PROJECT PROJECT PROJECT ; printf "$?\n${wov_REPO_TYPE}\n${wov_REPO_EXT}\n${wov_REPO_MSCODE}\n"' 0 4 '4' 'single' '' ''

  unset wov_REPO_TYPE wov_REPO_EXT wov_REPO_MSCODE
  rmdir src
  tr_test "success, no interaction needed" "iProjRepo_InteractiveNaming MP P P MP && echo $?" 0 1 "0"

  unset wov_REPO_TYPE wov_REPO_EXT wov_REPO_MSCODE
  mkdir src
  tr_test "quitting from errors" "iProjRepo_InteractiveNaming MP P P MP && echo $?" 1 1 '' <<EOF
Y
EOF

  unset wov_REPO_TYPE wov_REPO_EXT wov_REPO_MSCODE
  rmdir src
  tr_test "many, interactively" 'iProjRepo_InteractiveNaming MASTER PROJECT C D && printf "${wov_REPO_TYPE}\n${wov_REPO_EXT}\n${wov_REPO_MSCODE}\n"' 0 3 'many' 'MASTER/PROJECT' '' <<EOF
n
MASTER_PROJECT

EOF

  unset wov_REPO_TYPE wov_REPO_EXT wov_REPO_MSCODE
  mkdir src
  tr_test "single, interactively" 'iProjRepo_InteractiveNaming MASTER PROJECT C D > /dev/null && printf "${wov_REPO_TYPE}\n${wov_REPO_EXT}\n${wov_REPO_MSCODE}\n"' 0 3 'single' 'MASTER_PROJECT_PROJECTmsc' 'msc' <<EOF
n
msc
Y
EOF

  unset wov_REPO_TYPE wov_REPO_EXT wov_REPO_MSCODE
  tr_test "single, interactively and change repo" 'iProjRepo_InteractiveNaming MASTER PROJECT C D > /dev/null && printf "${wov_REPO_TYPE}\n${wov_REPO_EXT}\n${wov_REPO_MSCODE}\n"' 0 3 'single' 'mmm' 'msc' <<EOF
n
msc
n
mmm
Y
EOF


  tr_section "/naming and repos"
fi

tr_results
