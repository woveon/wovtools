#!/usr/bin/env bash
. /usr/local/bin/wtrunner


#tr_tests_off
#tr_vverbose
#tr_tests_on
tr_dir test1

tr_h1 "wov-push-container - $0"
tr_comment "Tests the wov-push-container. Assumes test1 has been created with 'test1.sh' test case"

tr_section 'basic'
{

  tr_test 'List microservices' \
    'wov-env --lms' 0 1 test1X

  tr_test 'clean container cache' \
    'wov-push-container --clean' 0 -1
  tr_run 'remove Docker image' 'docker image rm test1/test1x'

  tr_test 'push container check, build needed' \
    'wov-push-container-buildcheck test1x test1X' 1 -1

  tr_test 'push container check, git checked b/c dev and failed' \
    'wov-push-container-buildcheck --context wov-aws-va-grape-test1-dev test1x test1X' 4 -1

  tr_test 'push container check should say false' \
    '[[ `wov-push-container-buildcheck test1x test1X` == *"... no "*", building" ]]' 0 -1

  tr_test 'call push container, but only build, no push' \
    'wov-push-container -P test1X' 0 -1
  tr_run 'make sure image created' \
    "docker images -q test1/test1x | wc -l | tr -d '[:space:]'" 0 1 1
  tr_test 'push container check, just push needed' \
    'wov-push-container-buildcheck test1x test1X' 5 -1

  tr_test 'push container fully' \
    'wov-push-container -p test1X' 0 -1
}


tr_results
tr_popdir
