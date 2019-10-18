#!/usr/bin/env bash
. /usr/local/bin/wtrunner

#tr_vverbose
# tr_dir test1
tr_protectfile "wovtools/config.json"
tr_protectfile "wovtools/myconfig.json"
tr_protectfile "${HOME}/wovtools/config"
tr_protectdir  "test1" del


tr_h1 "wov-checkout - $0"
tr_comment "Tests the wov-checkout command. Assumes test1 project has been created with 'test011_init.sh'."
. test_common.sh
tcUseTestingContext

export PATH=$PATH:/usr/local/bin/wovlib
. wov-env-common


# --- set this because using wov-env-loader in non-project is a pain
WOVCONFIGF="${HOME}/.wovtools/config"

MTESTDIR="$(realpath .)"
MSC=X
#MASTER="$(basename $MTESTDIR)"
#PROJ=test1
#TESTDIR="${MTESTDIR}/${PROJ}"

{
  tr_section 'init'
  tr_section '/init'
}


tr_tests_on
#tr_tests_off


tr_vverbose
D=.delme
{
  tr_section 'checkenvs'

  echo "LADIR: ${LADIR}"
  wov-checkout --usercode "${TESTME}" --local-archives ${LADIR} --envs test1 X > $D <<EOF
Y
Y
Y
Y
EOF
  tr_comment "D:" ; cat "$D"

  tr_test "GLOBALDIR is repo location" \
    "cat $D | grep GLOBALDIR" \
    0 1 "GLOBALDIR=`pwd`"

  tr_test "check WOV_MASTERPROJECT" \
    "cat $D | sed -n -e 's/^WOV_MASTERPROJECT=//p'" \
    0 1 "test"

  tr_test "check WOV_PROJECT" \
    "cat $D | sed -n -e 's/^WOV_PROJECT=//p'" \
    0 1 "test1"

  tr_test "check MSCODE" \
    "cat $D | sed -n -e 's/^MSCODE=//p'" \
    0 1 "X"

  tr_test "check REPODIR" \
    "cat $D | sed -n -e 's/^REPODIR=//p'" \
    0 1 "test/test1_test1X"
  tr_test "check REPOEXT" \
    "cat $D | sed -n -e 's/^REPOEXT=//p'" \
    0 1 "test_test1_test1X"

  tr_test "check WOV_BASEDIR" \
    "cat $D | sed -n -e 's/^WOV_BASEDIR=//p'" \
    0 1 "`pwd`/test1_test1X"

  tr_test "check PROJSHORTCUT" \
    "cat $D | sed -n -e 's/^PROJSHORTCUT=//p'" \
    0 1 "test1X"

  echo "WOVCONFIGF: ${WOVCONFIGF}"
  cat "${WOVCONFIGF}"

  tr_test "check WOV_CODEREPOARCHIVE" \
    "cat $D | sed -n -e 's/^WOV_CODEREPOARCHIVE=//p'" \
    0 1 "`jq -r '.archives.coderepo' "${WOVCONFIGF}"`"

  tr_section '/checkenvs'
}

D1=.delme1
{
  tr_section 'checkjson'

  
  wov-checkout --usercode "${TESTME}" --local-archives ${LADIR} --config-only test1 X > $D1
  cat $D
  cat $D1

  tr_test "check .projects.test1X.dir" \
    "cat $D | sed -n -e 's/^WOV_BASEDIR=//p'" \
    0 1 "`jq -r '.projects.test1X.dir' ${D1}`"
  tr_test "check .projects.test1X.repo" \
    "cat $D | sed -n -e 's/^REPOEXT=//p'" \
    0 1 "`jq -r '.projects.test1X.repo' ${D1}`"
  tr_test "check .projects.test1X.reposerver" \
    "cat $D | sed -n -e 's/^WOV_CODEREPOARCHIVE=//p'" \
    0 1 "`jq -r '.projects.test1X.reposerver' ${D1}`"

  # Secrets Local Archive
  echo "LADIR: ${LADIR}"
  echo "se path: $(WovPathExt la se ${MASTER} ${PROJ})"
  echo "jq : $(jq -r '.projects.test1X.sub[0].dir' ${D1})"
  tr_test "check .projects.test1X.sub[0].dir" \
    "jq -r '.projects.test1X.sub[0].dir' ${D1}" 0 1  \
    "${LADIR}/searchive/$(WovPathExt la se ${MASTER} ${PROJ})"

  tr_test "check .projects.test1X.sub[0].repo" \
    "echo 'test_sea_${TESTME}'" \
    0 1 "`jq -r '.projects.test1X.sub[0].repo' ${D1}`"
  tr_test "check .projects.test1X.sub[0].reposerver" \
    "cat $D | sed -n -e 's/^WOV_CODEREPOARCHIVE=//p'" \
    0 1 "`jq -r '.projects.test1X.sub[0].reposerver' ${D1}`"

  # DataBase Local Archive
  tr_test "check .projects.test1X.sub[1].dir" \
  "jq -r '.projects.test1X.sub[1].dir' ${D1}" 0 1 \
    "${LADIR}/dbarchive/$(WovPathExt la db ${MASTER} ${PROJ})"
  tr_test "check .projects.test1X.sub[1].repo" \
    "echo 'test_test1_dba'" \
    0 1 "`jq -r '.projects.test1X.sub[1].repo' ${D1}`"
  tr_test "check .projects.test1X.sub[1].reposerver" \
    "cat $D | sed -n -e 's/^WOV_CODEREPOARCHIVE=//p'" \
    0 1 "`jq -r '.projects.test1X.sub[1].reposerver' ${D1}`"

  # DataSet Local Archive
  tr_test "check .projects.test1X.sub[2].dir" \
    "jq -r '.projects.test1X.sub[2].dir' ${D1}" 0 1 \
    "${LADIR}/dsarchive/$(WovPathExt la ds ${MASTER} ${PROJ})"
  tr_test "check .projects.test1X.sub[2].repo" \
    "echo 'test_dsa'" \
    0 1 "`jq -r '.projects.test1X.sub[2].repo' ${D1}`"
  tr_test "check .projects.test1X.sub[2].reposerver" \
    "cat $D | sed -n -e 's/^WOV_CODEREPOARCHIVE=//p'" \
    0 1 "`jq -r '.projects.test1X.sub[2].reposerver' ${D1}`"

  tr_section '/checkjson'
}



D2=.delme2
{
  tr_section 'overridemaster'

  tr_test "override master" "wov-checkout --usercode ${TESTME} --envs --master MASTER test1 X > $D2" 0 -1
  tr_test "GLOBALDIR is repo location" "cat $D2 | sed -n -e 's/^GLOBALDIR=//p'" 0 1 "`pwd`"
  tr_test "check WOV_MASTERPROJECT" "cat $D2 | sed -n -e 's/^WOV_MASTERPROJECT=//p'" 0 1 "MASTER"
  tr_test "check WOV_PROJECT" "cat $D2 | sed -n -e 's/^WOV_PROJECT=//p'" 0 1 "test1"
  tr_test "check MSCODE" "cat $D2 | sed -n -e 's/^MSCODE=//p'" 0 1 "X"
  tr_test "check REPODIR" "cat $D2 | sed -n -e 's/^REPODIR=//p'" 0 1 "MASTER/test1_test1X"
  tr_test "check REPOEXT" "cat $D2 | sed -n -e 's/^REPOEXT=//p'" 0 1 "MASTER_test1_test1X"
  tr_test "check WOV_BASEDIR" "cat $D2 | sed -n -e 's/^WOV_BASEDIR=//p'" 0 1 "$(cd .. ; pwd)/MASTER/test1_test1X"

  tr_test "check PROJSHORTCUT" "cat $D2 | sed -n -e 's/^PROJSHORTCUT=//p'" 0 1 "test1X"
  tr_test "check WOV_CODEREPOARCHIVE" "cat $D2 | sed -n -e 's/^WOV_CODEREPOARCHIVE=//p'" 0 1 "`jq -r '.archives.coderepo' "${WOVCONFIGF}"`"

  tr_section '/overridemaster'
}

{
  tr_section 'overrideshortcut'

  tr_test "override shortcut" "wov-checkout --usercode  ${TESTME} --envs --shortcut SHORT test1 X > $D2" 0 -1
  tr_test "GLOBALDIR is repo location" "cat $D2 | sed -n -e 's/^GLOBALDIR=//p'" 0 1 "`pwd`"
  tr_test "check WOV_MASTERPROJECT" "cat $D2 | sed -n -e 's/^WOV_MASTERPROJECT=//p'" 0 1 "test"
  tr_test "check WOV_PROJECT" "cat $D2 | sed -n -e 's/^WOV_PROJECT=//p'" 0 1 "test1"
  tr_test "check MSCODE" "cat $D2 | sed -n -e 's/^MSCODE=//p'" 0 1 "X"
  tr_test "check REPODIR" "cat $D2 | sed -n -e 's/^REPODIR=//p'" 0 1 "test/test1_test1X"
  tr_test "check REPOEXT" "cat $D2 | sed -n -e 's/^REPOEXT=//p'" 0 1 "test_test1_test1X"
  tr_test "check WOV_BASEDIR" "cat $D2 | sed -n -e 's/^WOV_BASEDIR=//p'" 0 1 "$(cd .. ; pwd)/test/test1_test1X"
  tr_test "check PROJSHORTCUT" "cat $D2 | sed -n -e 's/^PROJSHORTCUT=//p'" 0 1 "SHORT"
  tr_test "check WOV_CODEREPOARCHIVE" "cat $D2 | sed -n -e 's/^WOV_CODEREPOARCHIVE=//p'" 0 1 "`jq -r '.archives.coderepo' "${WOVCONFIGF}"`"

  tr_section '/overrideshortcut'
}

{
  tr_section 'overriderepo'

  tr_test "override shortcut" "wov-checkout --usercode ${TESTME} --envs --repo REPO test1 X > $D2" 0 -1
  tr_test "GLOBALDIR is repo location" "cat $D2 | sed -n -e 's/^GLOBALDIR=//p'" 0 1 "`pwd`"
  tr_test "check WOV_MASTERPROJECT" "cat $D2 | sed -n -e 's/^WOV_MASTERPROJECT=//p'" 0 1 "test"
  tr_test "check WOV_PROJECT" "cat $D2 | sed -n -e 's/^WOV_PROJECT=//p'" 0 1 "test1"
  tr_test "check MSCODE" "cat $D2 | sed -n -e 's/^MSCODE=//p'" 0 1 "X"
  tr_test "check REPODIR" "cat $D2 | sed -n -e 's/^REPODIR=//p'" 0 1 "test/test1_test1X"
  tr_test "check REPOEXT" "cat $D2 | sed -n -e 's/^REPOEXT=//p'" 0 1 "REPO"
  tr_test "check WOV_BASEDIR" "cat $D2 | sed -n -e 's/^WOV_BASEDIR=//p'" 0 1 "$(cd .. ; pwd)/test/test1_test1X"
  tr_test "check PROJSHORTCUT" "cat $D2 | sed -n -e 's/^PROJSHORTCUT=//p'" 0 1 "test1X"
  tr_test "check WOV_CODEREPOARCHIVE" "cat $D2 | sed -n -e 's/^WOV_CODEREPOARCHIVE=//p'" 0 1 "`jq -r '.archives.coderepo' "${WOVCONFIGF}"`"

  tr_section '/overriderepo'
}

{
  tr_section 'overridereposerver'

  tr_test "override shortcut" "wov-checkout --usercode ${TESTME} --envs --reposerver \"/REPOSERVER\" test1 X > $D2" 0 -1
  tr_test "GLOBALDIR is repo location" "cat $D2 | sed -n -e 's/^GLOBALDIR=//p'" 0 1 "`pwd`"
  tr_test "check WOV_MASTERPROJECT" "cat $D2 | sed -n -e 's/^WOV_MASTERPROJECT=//p'" 0 1 "test"
  tr_test "check WOV_PROJECT" "cat $D2 | sed -n -e 's/^WOV_PROJECT=//p'" 0 1 "test1"
  tr_test "check MSCODE" "cat $D2 | sed -n -e 's/^MSCODE=//p'" 0 1 "X"
  tr_test "check REPODIR" "cat $D2 | sed -n -e 's/^REPODIR=//p'" 0 1 "test/test1_test1X"
  tr_test "check REPOEXT" "cat $D2 | sed -n -e 's/^REPOEXT=//p'" 0 1 "test_test1_test1X"
  tr_test "check WOV_BASEDIR" "cat $D2 | sed -n -e 's/^WOV_BASEDIR=//p'" 0 1 "$(cd .. ; pwd)/test/test1_test1X"
  tr_test "check PROJSHORTCUT" "cat $D2 | sed -n -e 's/^PROJSHORTCUT=//p'" 0 1 "test1X"
  tr_test "check WOV_CODEREPOARCHIVE" "cat $D2 | sed -n -e 's/^WOV_CODEREPOARCHIVE=//p'" 0 1 "/REPOSERVER"

  tr_section '/overridereposerver'
}

{
  tr_section  'checkouttest'

  tr_test "checkout from repo fails because no repo" \
    "wov-checkout --usercode ${TESTME} --reposerver '${MTESTDIR}/${PROJ}remoterepo ' 'test2' 'Y'" \
    105 -1

  tr_test "checkout from repo fails because looking for single project" \
    "wov-checkout -vv --debugmode --usercode ${TESTME} --reposerver '${MTESTDIR}/${MASTER}remoterepo' '${PROJ}' '${MSC}'" \
    105 -1

  tr_test_skip "TODO: checkout from repo fails because existing checkout points to different repo" \
    "wov-checkout -vv --debugmode --usercode ${TESTME} --reposerver '${MTESTDIR}/${MASTER}remoterepo' '${PROJ}'" \
    108 -1

  tr_tests_on
  #wov-checkout -vv --debugmode --usercode ${TESTME} --reposerver "${MTESTDIR}/${MASTER}remoterepo" \
  #                             --local-archives "${MTESTDIR}/${MASTER}localarchives"  "${PROJ}"

  tr_test "checkout from repo fails because existing checked out version" \
    "wov-checkout -vv --debugmode --usercode ${TESTME} --reposerver '${MTESTDIR}/${MASTER}remoterepo' "`
                    `"--local-archives '${MTESTDIR}/${MASTER}localarchives' '${PROJ}'" \
    0 -1

  tr_vverbose
  tr_test "checkout from repo fails because existing checked out version" \
    "wov-checkout -vv --debugmode --usercode ${TESTME} --reposerver \"${MTESTDIR}/${MASTER}remoterepo\" --local-archives \"${MTESTDIR}/${MASTER}localarchives\" ${PROJ}" \
    107 -1

  tr_dir test1
  tr_test "wov-env should work" "wov-env -e" 0 -1
  trap - Exit
  tr_popdir

  tr_section '/checkouttest'
}


tr_results
