#!/usr/bin/env bash
. /usr/local/bin/wtrunner

#tr_tests_off
#tr_tests_on
#tr_vverbose



tr_h1 "wov-deploy - $0"
tr_comment "Tests the wov-deploy. Assumes test1 project and DB Archive have been created with 'test001_init.sh'."

tr_test "help - out of project directory" "wov-deploy -h" 0 -1
tr_dir test1

{
  tr_section 'basic'

  tr_test "help" \
    "wov-deploy -h" 0 -1
  tr_test "list deployable versions" \
    "wov-deploy -lversions" 0 2 "1_1" "2_2"
  tr_section '/'
}

{
  tr_section 'checkContainers'

  tr_test "check containers exist" \
    "wov-deploy --context wov-aws-va-grape-test1-cw --check-containers" 0 -1

  tr_test "check containers exist on version 1_1" \
    "wov-deploy --pver 1 --check-containers" 0 -1

  tr_test "check container 9999_1 does not exist" \
    "wov-deploy -v --pver 9999 --check-containers" 1 -1

  tr_section '/'
}

{
  tr_section 'dryRun'

  tr_test "dryRun failing to add type of deploy" \
    "wov-deploy --context wov-aws-va-grape-test1-cw --dry-run" 1 -1

  tr_test "dryRun --dev should pass" \
    "wov-deploy --context wov-aws-va-grape-test1-cw --dry-run --dev" 0 -1

  tr_test "dryRun --stage should pass" \
    "wov-deploy -v --context wov-aws-va-grape-test1-cw --dry-run --stage" 0 -1

  tr_test "dryRun --dev should pass" \
    "wov-deploy --pver 1 --context wov-aws-va-grape-test1-cw --dry-run --dev" 0 -1

  tr_test "dryRun --stage should pass" \
    "wov-deploy --pver 1 -v --context wov-aws-va-grape-test1-cw --dry-run --stage" 0 -1

}


{
  tr_section 'deploy'

  tr_run  'delete namespace' 'kubectl delete ns test1-cw'
  tr_test 'create namespace' "kubectl create namespace test1-cw" 0 -1

  tr_test "deploy dev" \
    "wov-deploy -v --context wov-aws-va-grape-test1-cw --dev" 0 -1

  tr_test "make sure it exists (and is dev)" \
    "kubectl -n test1-cw get deployments -o json | jq -r '.items[0] | \"\(.kind)\n\(.metadata.name)\n\(.spec.template.spec.containers[0].image)\"'" 0 3 "Deployment" "test1x" "$(wov-env --context wov-aws-va-grape-test1-cw --var WOV_ARCHIVEREPOSITORY)/test1/test1x:cw_dev"

  tr_test "deploy stage" \
    "WOV_DEBUGMODE=1 wov-deploy -v --context wov-aws-va-grape-test1-cw --stage" 0 -1

  tr_test_skip "patch deployment"

  tr_test_skip "--retain test"

  tr_section '/'
}


tr_popdir
tr_results
