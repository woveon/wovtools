#!/usr/bin/env bash
. /usr/local/bin/wtrunner

tr_tests_off
tr_vverbose
tr_dir test1

tr_h1 "wov-push-k8s - $0"
tr_comment "Tests the wov-push-k8s. Assumes test1 has been created with 'test1.sh' test case"

tr_section 'basic'
{
  tr_tests_on
 
  tr_test "wov-push-k8s help" \
    "wov-push-k8s -h" 0 -1

  tr_test "call a check but with wrong origin" \
    "wov-push-k8s --context local:wov-aws-va-grape-test1-cw --check" 1 -1

  tr_test "call a check with self origin" \
    "wov-push-k8s --context self:wov-aws-va-grape-test1-cw --check" 0 -1

  tr_test "push but with bad origin so fail" \
    "wov-push-k8s --context local:wov-aws-va-grape-test1-cw --push" 1 -1

  tr_test "push with good origin so pass" \
    "wov-push-k8s --context self:wov-aws-va-grape-test1-cw --push" 0 -1
}

tr_popdir
