#!/usr/bin/env bash
. /usr/local/bin/wtrunner

#tr_tests_on
#tr_vverbose
#tr_protectfile "wovtools/config.json"
#tr_protectfile "wovtools/myconfig.json"

tr_h1 "wov-push-db - $0"
tr_comment "Tests the wov-push-db. Assumes test1 project and DB Archive have been created with 'test1.sh'."

. test_common.sh
tcUseTestingContext
tr_dir test1


{
  tr_section 'init'
  tr_test "init the Adb" "wov-init-wovdb Adb" 0 -1
  tr_section '/init'
}

tr_verbose 
{
  tr_section 'basic'
  tr_tests_off
  tr_tests_on


  tr_test "wov-push-db help" \
    "wov-push-db -h" 0 -1

  tr_comment "ensure a database and delta exists"
  tr_run "shut down any local postgres server" \
    "wov-db --context wov-aws-va-grape-test1-${TESTME} --docker-postgres-stop"
  tr_run "bring up a local postgres server" \
    "wov-db --context wov-aws-va-grape-test1-${TESTME} --docker-postgres-start Adb"
  tr_test "create the database" \
    "wov-db --context wov-aws-va-grape-test1-${TESTME} --wdb-createinstance Adb" 0 -1

  tr_test "wov-push-db push check fails because of deltas" \
    "wov-push-db --check" 1 -1

  tr_run 'check log 1' 'wov-db --wdb-log'
  tr_run 'wov-env' 'wov-env --var WOV_PVER'
#  tr_run "asdf" "wov-push-db --snapshot X"

  tr_run 'git push' 'git commit -a -m "testing commit" ; git push'

  tr_run 'wov-env' 'wov-env --var WOV_PVER --var WOV_WORKINGCONTEXT'

  tr_tests_on
  tr_vverbose
  tr_test "check in db deltas" \
    "wov-push-db --snapshot Adb X" 0 -1

  tr_run 'check log 2' 'wov-db --wdb-log'
  tr_run 'git branch' 'git branch'
  # 2 | test1db | 2 | 2_1 | 2 | 1 | X
  tr_run 'wov-env' 'wov-env --var WOV_PVER --var WOV_WORKINGCONTEXT'

  TMP=$(wov-db --wdb-log)
  TMP=( ${TMP//|/ } )
  V=${TMP[4]}
  tr_test "shapshot X should be set" \
    "echo ${TMP[4]} ${TMP[6]}" 0 1 "$V X"

  tr_test "change snapshot" \
    "wov-push-db --snapshot Adb Y" 0 -1
  tr_run 'check log 3' 'wov-db --wdb-log'
  tr_run 'wov-env' 'wov-env --var WOV_PVER --var WOV_WORKINGCONTEXT'

  TMP=$(wov-db --wdb-log)
  TMP=( ${TMP//|/ } )
  tr_test "shapshot Y should be set" \
    "echo ${TMP[4]} ${TMP[6]}" 0 1 "$V Y"

  tr_section '/basic'
}

tr_popdir
tr_results
