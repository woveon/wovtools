#!/usr/bin/env bash
. /usr/local/bin/wtrunner

tr_tests_off
tr_vverbose
tr_dir test1

tr_h1 "wov-db"
tr_comment "Tests the wov-db command. Assumes test1 has been created with 'test1.sh' test case"

{
  tr_section 'non-database-specific'

  tr_test 'help' 'wov-db -h' 0 -1

  tr_test 'list wov databases' 'wov-db -lwdb' 0 1 ''

  tr_test 'list wov data sets' 'wov-db -lds' 0 1 ''
  tr_section '/non-database-specific'
}

{
  tr_section 'wov-databases'


  tr_test 'info assuming db on bad context errors' \
    'wov-db --context wov-aws-va-grape-fail-fail  --info' 1 -1

  tr_test 'info on non-existent db errors' \
    'wov-db A --info' 1 -1

  tr_test 'create a Wov database but missing values' \
    'wov-db --context wov-aws-va-grape-fail-cw --wdb-create A' 1 -1

  tr_test 'create a Wov database with correct context but bad DB' \
    'wov-db --context wov-aws-va-grape-test1-cw --wdb-create A' 1 -1

  tr_tests_on
  tr_test 'stop any running db so we know it has correct user and password' \
    'wov-db --docker-postgres-stop' 0 -1

  tr_test 'start local postgres db' \
    'wov-db --context wov-aws-va-grape-test1-cw --docker-postgres-start test1db' 0 -1

  tr_test 'create a Wov database with correct context' \
    'wov-db --context wov-aws-va-grape-test1-cw --wdb-create test1db' 0 -1

  tr_test 'info on db shows values (assumed db)' \
    'wov-db --context wov-aws-va-grape-test1-cw --info' 0 -1

  tr_test 'info on db shows values' \
    'wov-db --context wov-aws-va-grape-test1-cw test1db --info' 0 -1

  tr_section '/wov-databases'
}


{
  tr_section 'wov-db-create-and-init'
  tr_comment 'NOTE: requires a running local database from above section'

  tr_test 'Should be empty database' \
    'wov-db --context wov-aws-va-grape-test1-cw test1db -c "\d"' 0 1 "No relations found."

  tr_test_skip 'database server wait --dbs-wait'

  tr_test 'Create and init Wov database' \
    'wov-db --context wov-aws-va-grape-test1-cw test1db --wdb-init' 0 -1
  tr_section '/wov-db-create-and-init'
}


{
  tr_section 'wov-db-server'
  tr_test_skip 'create a server'
  tr_test_skip 'wait for it'
  tr_section '/wov-db-server'
}


{
  tr_section 'wov-db-cmds'

  tr_test 'Schema gets returned' \
    'wov-db --context wov-aws-va-grape-test1-cw test1db --schema | wc -l | tr -d "[:space:]"' 0 1 36

  tr_test 'Schema diff against 0 but no version' \
    'wov-db --context wov-aws-va-grape-test1-cw test1db --schema-diff' 1 1 "ERROR: no schema for database 'test1db', schema version '0'."

  tr_test_skip 'schema hash'

  tr_test_skip 'check in schema'
  tr_test_skip 'commit db version'
  tr_test_skip 'db change'
  tr_test_skip 'schema diff returns value'

  tr_section 'wov-db-cmds'
}


{
  tr_section 'wov-db-data'

  tr_test_skip 'generate a data set'
  tr_test_skip 'list a data set'
  tr_test_skip 'data set : schema'
  tr_test_skip 'data set : clear'
  tr_test_skip 'data set : data'
  tr_test_skip 'data set : reload'
  tr_test_skip 'data set : full'

  tr_section '/wov-db-data'
}


tr_results
tr_popdir
