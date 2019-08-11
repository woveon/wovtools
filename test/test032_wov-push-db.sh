#!/usr/bin/env bash
. /usr/local/bin/wtrunner

tr_tests_off
tr_vverbose
tr_dir test1

tr_h1 "wov-push-db - $0"
tr_comment "Tests the wov-push-db. Assumes test1 has been created with 'test1.sh' test case"

tr_section 'basic'
{
  tr_tests_on

  tr_test "wov-push-db help" \
    "wov-push-db -h" 0 -1

  tr_run "ensure a delta exists" "echo '# test delta' >> wovtools/db/test1db.deltas"

  tr_test "wov-push-db push check" \
    "wov-push-db --push-check" 1 -1

  tr_test "check in db deltas" \
    "wov-push-db"

}

tr_popdir
