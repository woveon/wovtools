#!/usr/bin/env bash

. /usr/local/bin/wtrunner

#tr_tests_on
#tr_tests_off

tr_h1 "wov-env commands : $0"
tr_comment 'This runs on existing project from test1.sh'

tr_h2 'in and out of project'

tr_section 'wov-env NotInAProject'
{
  tr_comment 'Test that basic functionality of WovTools works outside of a WovTools project.'

  tr_section 'wov-env-simple'
  {
    tr_test "vh-label" \
      'wov-env --vh-label' 0 1 "0.1"
    tr_test "version" \
      'wov-env --version' 0 1 "2"
    tr_test "version and vh-label" \
      'wov-env --version --vh-label' 0 2 "2" "0.1"
    tr_section '/wov-env-simple'
  }

  tr_section 'wov-env-again'
  {
    tr_comment 'Move into project and test again'

    tr_test "ensure test1 directory where simple wovtools projec texists" \
      '[ -e test1 ]' 0 1 ''
    tr_dir test1

    tr_test "vh-label" \
      'wov-env --vh-label' 0 1 "0.1"
    tr_test "version" \
      'wov-env --version' 0 1 "2"
    tr_test "version and vh-label" \
      'wov-env --version --vh-label' 0 2 "2" "0.1"
    tr_section '/wov-env-again'
  }

  tr_section '/NotInAProject'
}




tr_h2 'Context in wov-env-loader'

tr_section 'context-tests'
{

  tr_test "simple context" \
    'wov-env --context wov-aws-va-grape-test1-cw --var WOV_VERSION ; wov-env --context wov-aws-va-grape-test1-cw --var WOV_SVER' \
    0 2 \
    '2' '[ "${result}" != "" ]'

  tr_test "context set test" \
    'wov-env --context wov-aws-va-grape-test1-cw --var WOV_CONTEXT' \
    0 1 'wov-aws-va-grape-test1-cw'

  tr_test "workingcontext test" \
    'wov-env --context local:wov-aws-va-grape-test1-cw --var WOV_CONTEXT --var WOV_ORIGIN' \
    0 2 'wov-aws-va-grape-test1-cw' 'local'

  tr_test "workingcontext and origin cmdline conflict, cmdline wins" \
    'wov-env --context local:wov-aws-va-grape-test1-cw --origin ll --var WOV_CONTEXT --var WOV_ORIGIN --var WOV_WORKINGCONTEXT' \
    0 3 'wov-aws-va-grape-test1-cw' 'll' 'll:wov-aws-va-grape-test1-cw'

  tr_test "origin from file" \
    'wov-env --context wov-aws-va-grape-alywan-cw  --var WOV_ORIGIN --var WOV_CONTEXT --var WOV_WORKINGCONTEXT' \
    0 3 "local" "wov-aws-va-grape-alywan-cw" "local:wov-aws-va-grape-alywan-cw"

  tr_test "origin from context" \
    'wov-env --context ll:wov-aws-va-grape-alywan-cw --var WOV_ORIGIN --var WOV_CONTEXT --var WOV_WORKINGCONTEXT' \
    0 3 "ll" "wov-aws-va-grape-alywan-cw" "ll:wov-aws-va-grape-alywan-cw"

  tr_test "origin from cmdline switch" \
    'wov-env --context wov-aws-va-grape-alywan-cw --origin LL --var WOV_ORIGIN --var WOV_CONTEXT --var WOV_WORKINGCONTEXT' \
    0 3 "LL" "wov-aws-va-grape-alywan-cw" "LL:wov-aws-va-grape-alywan-cw"

  tr_section '/context-tests'
}



tr_h2 'wov-env'
{
  tr_section 'wov-env-full'


  tr_test "wov-env --vh-label" \
    'wov-env --vh-label 2> /dev/null' \
    0 1 "0.1"


  tr_doctest "in wov-env, provide a full context and check origin, context and working context"
  tr_test "wov-env origin from file" \
    'wov-env --context wov-aws-va-grape-alywan-cw --var WOV_ORIGIN --var WOV_CONTEXT --var WOV_WORKINGCONTEXT' \
    0 3 "local" "wov-aws-va-grape-alywan-cw" "local:wov-aws-va-grape-alywan-cw"

  tr_test "wov-env origin from context" \
    'wov-env --context ll:wov-aws-va-grape-alywan-cw --var WOV_ORIGIN --var WOV_CONTEXT --var WOV_WORKINGCONTEXT' \
    0 3 "ll" "wov-aws-va-grape-alywan-cw" "ll:wov-aws-va-grape-alywan-cw"


  tr_test "Version" 'wov-env --version' 0 1 '2'
  tr_test "--rvAWS va"  'wov-env --rcAWS va'  0 1 'us-east-1'
  tr_test "--rvAWS iad" 'wov-env --rcAWS iad' 0 1 'us-east-1'
  tr_test "--rvAWS foo" 'wov-env --rcAWS foo' 1 1 ''


  tr_test "-e echos same args as ECHOVARS array has" \
    'wov-env -e | wc -l | tr -d "[:space:]" ' \
    0 1 "$(. wov-env ; echo "${#ECHOVARS[@]}")"

  tr_test "-e echos correct values like context" \
    'wov-env --context ll:wov-aws-va-grape-alywan-cw -e | grep WOV_CONTEXT' \
    0 1 "WOV_CONTEXT='wov-aws-va-grape-alywan-cw'"

  tr_test "-e echos correct values like context" \
    'wov-env --origin LL --context ll:wov-aws-va-grape-alywan-cw -e | grep WOV_CONTEXT' \
    0 1 "WOV_CONTEXT='wov-aws-va-grape-alywan-cw'"

  tr_test "-e echos correct values like context" \
    'wov-env --origin LL --context ll:wov-aws-va-grape-alywan-cw -e | grep WOV_ORIGIN' \
    0 1 "WOV_ORIGIN='LL'"

  tr_test "-E is 0 lines" \
    'wov-env -E | wc -l | tr -d "[:space:]" ' \
    0 1 "0"

  tr_test "-E has WOV_ORIGIN" \
    'wov-env -E | grep -oh WOV_ORIGIN' \
    0 1 'WOV_ORIGIN'

  tr_test "-E has WOV_ORIGIN" \
    'wov-env -E | grep -oh WOV_ORIGIN' \
    0 1 'WOV_ORIGIN'


  tr_test "Test ConfigurationMap of a Microservice : local cw" \
    'wov-env --context local:wov-aws-va-grape-test1-cw --cm test1X | grep -e "WOV_ME=" -e "WOV_test1db_port=" -e "WOV_test1db_database=" -e "WOV_www_api_url=" | sort' \
    0 4 'WOV_ME=cw' 'WOV_test1db_database=test1cw' 'WOV_test1db_port=65432' 'WOV_www_api_url=api-cw.test1.com'

  tr_test "Test ConfigurationMap of a Microservice: self cw" \
    'wov-env --context wov-aws-va-grape-test1-cw --origin self --cm test1X | grep -e "WOV_ME=" -e "WOV_test1db_port=" -e "WOV_test1db_database=" -e "WOV_www_api_url=" | sort' \
    0 4 'WOV_ME=cw' 'WOV_test1db_database=test1cw' 'WOV_test1db_port=5432' 'WOV_www_api_url=api-cw.test1.com'

  tr_test "Test ConfigurationMap of a Microservice: local dev" \
    'wov-env --context wov-aws-va-grape-test1-dev --origin local --cm test1X | grep -e "WOV_ME=" -e "WOV_STAGE=" -e "WOV_test1db_port=" -e "WOV_test1db_database=" -e "WOV_www_api_url=" | sort' \
    0 5 'WOV_ME=cw' 'WOV_STAGE=dev' 'WOV_test1db_database=test1dev' 'WOV_test1db_port=65432' 'WOV_www_api_url=api-dev.test1.com'

  tr_test "Test Secrets of a Microservice : local cw" \
    'wov-env --context local:wov-aws-va-grape-test1-cw --se test1X | grep -oh -e "WOV_test1db_password=" | sort' \
    0 1 'WOV_test1db_password='

  tr_test 'Provider Returns 3 values' \
    'wov-env --provider | grep -oh -e "AWS_REGION='"'"'us-east-1'"'"'" -e "AWS_ZONES=" -e "AWS_VPC=" ' \
    0 3 'AWS_REGION='"'"'us-east-1'"'"'' 'AWS_ZONES=' 'AWS_VPC='


  tr_test_skip 'wov-env --health'

  tr_test 'List microservices --lms' \
    'wov-env --lms' 0 1 'test1X'

  tr_test '--envs works' \
    'wov-env --envs | grep -oh -e "WOV_SVER=" -e "WOV_test1db_database=" | sort' \
    0 2 'WOV_SVER=' 'WOV_test1db_database='

  tr_test '--conf length' \
    "wov-env --conf | wc -l | tr -d '[:space:]'" \
    0 1 0
  tr_test '--conf ' \
    "wov-env --conf | grep -oh -e \"WOV_FLAVOR='grape'\"" \
    0 1 "WOV_FLAVOR='grape'"

  tr_test "--exports works" \
    "wov-env --exports | grep -oh \"export WOV_PROVIDER='aws'\"" \
    0 1 "export WOV_PROVIDER='aws'"

  tr_test "--secrets dump" \
    'wov-env --secrets | tail +4 | jq -r ".test1X.port"' \
    0 1 80

  tr_test "--var" \
    'wov-env --var WOV_STAGE' 0 1 'cw'
  tr_test "--var" \
    'wov-env --context wov-aws-va-grape-test1-dev --var WOV_STAGE' 0 1 'dev'



  tr_section 'wov-env-res'
  {
    tr_comment 'wov-env resource naming tests'

    tr_test 'Subnets'           'wov-env --res SN RES ZONE'          0 1 'RES-sn-ZONE'
    tr_test 'DB SN'             'wov-env --res DBSN DB SN ZONE'      0 1 'DB-dbsn-SNZONE' 
    tr_test 'DB subnet group'   'wov-env --res DBSNG RES'            0 1 'RES-dbsng'
    tr_test 'DB security group' 'wov-env --res DBSG DB'              0 1 'DB-dbsg'
    tr_test 'DB Route Table'    'wov-env --res DBRT DB'              0 1 'DB-dbrt'
    tr_test 'Security Group'    'wov-env --res SG RES Y'             0 1 'RES-SG-Y'
    tr_test 'DB Name'           'wov-env --res DB CLUSTER localhost' 0 1 'localhost'
    tr_test 'DB Name'           'wov-env --res DB CLUSTER NAME'      0 1 'CLUSTER-db-NAME'
    tr_test 'Peer Connection'   'wov-env --res PEERCONN CLUSTER'     0 1 'CLUSTER-peerconn'
    tr_test 'DB DNS'            'wov-env --res DNS wov-aws-va-grape alywandev' 0 1 'wov-aws-va-grape-db-alywandev.cipwuxrfsmqo.us-east-1.rds.amazonaws.com'
    tr_section '/wov-env-res'
  }

  tr_section '/wov-env-full'
}


tr_vverbose
{
  tr_section 'wov-env-build'
  tr_comment 'This is responsible for building the secrets and configuration information for clusters.'

  wov-env-build --clean
  tr_test 'Clean cluster directory' \
    'ls wovtools/cache/clusters | wc -l | tr -d "[:space:]" ' 0 1 0 
  tr_test 'Build a Configuration' \
    'wov-env-build --context self:wov-aws-va-grape-test1-cw --config' 0 -1 ''
  tr_test 'One cluster configuration should exist' \
    'ls wovtools/cache/clusters ' 0 1 'self__wov-aws-va-grape-test1-cw'
  tr_test 'One file config.json should exist' \
    'ls wovtools/cache/clusters/self__wov-aws-va-grape-test1-cw | wc -l | tr -d "[:space:]"' 0 1 '1'

tr_tests_on
  wov-env-build --clean
  tr_test 'Clean cluster directory again' \
    'ls wovtools/cache/clusters | wc -l | tr -d "[:space:]" ' 0 1 0 
  tr_test 'Build Cluster Config' \
    'wov-env-build --context self:wov-aws-va-grape-test1-cw --cluster' 0 -1 ''
  tr_test '4 dirs and config.json should exist' \
    'cd wovtools/cache/clusters/self__wov-aws-va-grape-test1-cw ; ls' 0 4 'cm' 'config.json' 'k8s' 'se'
  tr_test 'cm/test1X should have WOV_test1db_port=' \
    'grep -oh "WOV_test1db_port=" wovtools/cache/clusters/self__wov-aws-va-grape-test1-cw/cm/test1X' \
    0 1 'WOV_test1db_port='
  tr_test 'se/test1X should have WOV_test1db_password=' \
    'grep -oh "WOV_test1db_password=" wovtools/cache/clusters/self__wov-aws-va-grape-test1-cw/se/test1X' \
    0 1 'WOV_test1db_password='

  tr_section '/wov-env-build'
}


tr_results
tr_popdir
