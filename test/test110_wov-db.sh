#!/usr/bin/env bash
. /usr/local/bin/wtrunner

#tr_tests_off
tr_vverbose
PROJ=test1

tr_h1 "wov-db"
tr_comment "Tests the wov-db command. Assumes project test1 has been created."
if [ ! -e "${PROJ}" ]; then echo "ERROR: project '${PROJ}' does not exist. Run the 'test011_init.sh' test to create it."; exit 1; fi

tr_dir test1
tr_run 'set origin to here' 'wov-env --set-origin here'
tr_protectfile "wovtools/config.json"
tr_protectfile "wovtools/myconfig.json"



{
  tr_section 'non-database-specific'

  tr_test 'help' 'wov-db -h' 0 -1

  tr_test_todo 'here, need to delete and rebuild the database Archive.'

  # NOTE: this has failed here below because of entries in wovtools/(my)config.json which were left over from a previous test
  tr_test 'list wov databases' 'wov-db -lwdb' 0 -1 ''

  tr_test 'list wov data sets' 'wov-db -lds' 0 -1 ''
  tr_section '/non-database-specific'
}

{
  tr_section 'wov-database-errors'

  tr_test 'ensure bad context error' 'wov-env --context wov-aws-va-grape-fail-fail --exports -e' 102 -1

  tr_test 'info assuming db on bad context errors' \
    'wov-db --context wov-aws-va-grape-fail-fail' 102 -1

  tr_test 'info assuming db on bad context errors' \
    'wov-db --context wov-aws-va-grape-fail-fail  --info' 102 -1

  tr_test 'info on non-existent db errors' \
    'wov-db A --info' 201 -1

  tr_section '/wov-database-errors'
}


{
  tr_section 'wov-database-inst'

  #tr_test 'clean up old Adb secrets' "rm -Rf wovtools/secrets/A*db.json" 0 -1
  tr_test 'clean up old Adb secrets' "rm -Rf wovtools/secrets/Adb*.json" 0 -1
  tr_test 'clean up old Adb archive' "rm -Rf wovtools/db/archive/A*" 0 -1

  tr_test 'create a Wov database instance but missing values' \
    'wov-db --context wov-aws-va-grape-fail-cw --wdb-createinstance Adb' 203 -1

  tr_test 'create a WovDataBase' "wov-init-wovdb Adb" 0 -1

  tr_test 'create a Wov database with correct context but bad DB' \
    'wov-db --context wov-aws-va-grape-test1-cw --wdb-createinstance A' 203 -1

  tr_test 'stop any running db so we know it has correct user and password' \
    'wov-db --docker-postgres-stop' 0 -1

  tr_test 'start local postgres db' \
    'wov-db --context wov-aws-va-grape-test1-cw --docker-postgres-start Adb' 0 -1

  tr_test 'create a Wov database with correct context' \
    'wov-db --context here:wov-aws-va-grape-test1-cw --wdb-createinstance Adb' 0 -1

  tr_test 'info on db shows values (assumed db)' \
    'wov-db --context wov-aws-va-grape-test1-cw --info' 0 -1

  tr_test 'info on db shows values' \
    'wov-db --context wov-aws-va-grape-test1-cw Adb --info' 0 -1

  tr_section '/wov-database-inst'
}


{
  tr_section 'wov-db-create-and-init'
  tr_comment 'NOTE: requires a running local database from above section'

  tr_test 'Should be empty database' \
    'wov-db --context wov-aws-va-grape-test1-cw Adb -c "\d"' 0 1 "No relations found."

  tr_test_skip 'database server wait --dbs-wait'

  tr_test 'Create and init Wov database' \
    'wov-db --context wov-aws-va-grape-test1-cw --wdb-init Adb' 0 -1
  tr_section '/wov-db-create-and-init'
}


{
  tr_section 'wov-db-server'
  tr_test_todo 'create a server'
  tr_test_todo 'wait for it'
  tr_section '/wov-db-server'
}


{
  tr_section 'wov-db-cmds'

  tr_test 'Schema gets returned' \
    'wov-db --context wov-aws-va-grape-test1-cw Adb --schema | wc -l | tr -d "[:space:]"' 0 1 36

  tr_test 'Schema diff against 0 but no version' \
    'wov-db --context wov-aws-va-grape-test1-cw Adb --schema-diff 0' 1 1 "ERROR: no schema for database 'Adb', schema version '0'."

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


tr_popdir
tr_results
