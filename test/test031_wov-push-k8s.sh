#!/usr/bin/env bash
. /usr/local/bin/wtrunner

#tr_tests_off
#tr_vverbose
tr_dir test1

tr_h1 "wov-push-k8s - $0"
tr_comment "Tests the wov-push-k8s. Assumes test1 has been created with 'test1.sh' test case"

{
  tr_section 'wov-push-k8s-checks'

  tr_test "wov-push-k8s help" \
    "wov-push-k8s -h" 0 -1

  tr_test "clear cluster cache" "wov-env --clear-cluster-cache" 0 -1

  tr_test "make sure clusters directory no longer exists now after cleared" \
    "ls wovtools/cache/clusters" 1 -1

  tr_test "call a check but with wrong origin, but still corrects" \
    "wov-push-k8s --context local:wov-aws-va-grape-test1-cw --check" 0 -1

  tr_test "make sure cluster cache has 2 dirs now after cleared" \
    "ls wovtools/cache/clusters" 0 2 "local__wov-aws-va-grape-test1-cw" "self__wov-aws-va-grape-test1-cw"

  tr_test "call a check with self origin" \
    "wov-push-k8s --context self:wov-aws-va-grape-test1-cw --check" 0 -1
  tr_section '/wov-push-k8s-checks'
}

{
  tr_section 'wov-push-k8s-push'

  #tr_tests_on

  # Get var
  AE=`jq -r '.archive.env' ~/.wovtools`
  tr_run "reset .archive.env to ''" \
    "cat wovtools/config.json | jq -r '.archive.env=\"\"' > wovtools/config.json_ ; mv wovtools/config.json_ wovtools/config.json" 

  tr_test "push but fail because WOV_ARCHIVEENV not set." \
    "wov-push-k8s --push" 1 -1

  tr_run "reset .archive.env in wovtools/config.json from ~/.wovtools" \
    "cat wovtools/config.json | jq -r '.archive.env=\"${AE}\"' > wovtools/config.json_ ; mv wovtools/config.json_ wovtools/config.json" 
  tr_run "set .archive.env to " \
    "cat wovtools/config.json | jq -r '.archive.env'"


  tr_test "push success after being set above. assiming context" \
    "wov-push-k8s --push" 0 -1

  tr_test "push with good origin so pass" \
    "wov-push-k8s --context self:wov-aws-va-grape-test1-cw --push" 0 -1

  tr_test "push but unknown origin but still uses self" \
    "wov-push-k8s --context wov-aws-va-grape-test1-cw --push" 0 -1

  tr_test "push but with bad origin but still uses self" \
    "wov-push-k8s --context local:wov-aws-va-grape-test1-cw --push" 0 -1

  tr_section '/wov-push-k8s-push'
}

tr_popdir
tr_results
