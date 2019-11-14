#!/usr/bin/env bash
. /usr/local/bin/wtrunner

#tr_tests_off
tr_vverbose
. test_common.sh
tcUseTestingContext

tr_h1 "wov-db"
tr_comment "Tests the wov-db command. Assumes project test1 has been created."
if [ ! -e "${PROJ}" ]; then echo "ERROR: project '${PROJ}' does not exist. Run the 'test011_init.sh' test to create it."; exit 1; fi

tr_dir test1
tr_run 'set origin to here' 'wov-env --set-origin here'
tr_protectfile "wovtools/config.json"
tr_protectfile "wovtools/myconfig.json"



tcWipeWovDB Adb
#tr_run  "rm Adb files"   "rm -Rf wovtools/db/archive/Adb"
#tr_run  "rm Adb files"   "rm -Rf wovtools/db/Adb.deltas"
#tr_run  "rm Adb secrets" "rm -Rf wovtools/secrets/Adb*.json"
tr_test 'create a WovDataBase to start' "wov-init-wovdb --context \"${USECLUSTER}-${PROJ}-${TESTME}\" Adb" 0 -1


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

  tr_test 'ensure bad context error' "wov-env --context ${USECLUSTER}-fail-fail --exports -e" 102 -1

  tr_test 'info assuming db on bad context errors' \
    "wov-db --context ${USECLUSTER}-fail-fail" 102 -1

  tr_test 'info assuming db on bad context errors' \
    "wov-db --context ${USECLUSTER}-fail-fail  --info" 102 -1

  tr_test 'info on non-existent db errors' \
    'wov-db A --info' 201 -1

  tr_section '/wov-database-errors'
}

{
  tr_section 'wov-database-start'

  tr_run "make sure docker container is not running" "docker stop postgres-here"

  tr_test 'start a HERE WovDB' "wov-db --context ${USECLUSTER}-${PROJ}-${TESTME} Adb --start" 0 -1

  tr_test "version test" "wov-db --context ${USECLUSTER}-${PROJ}-${TESTME} Adb --wdbver" 0 -1

  tr_test_skip 'wait for WovDB' "wov-db --context ${USECLUSTER}-test1-${TESTME} Adb --wait " 0 -1

  tr_test 'test WovDB' "wov-db --context ${USECLUSTER}-test1-${TESTME} Adb --test" 0 -1

  tr_section '/wov-database-start'
}

{
  tr_section 'wov-database-instance'

#  tr_exit
#  tr_test 'clean up old Adb secrets' "rm -Rf wovtools/secrets/Adb*.json" 0 -1
#  tr_test 'create a Wov database instance but missing secret files' \
#    "wov-db --context ${USECLUSTER}-fail-${TESTME} Adb --wdb-create" 103 -1

  tr_run "delete Adb.json"       "echo '{}' > wovtools/secrets/Adb.json"
  tr_run "blank Adb_testme.json" "echo '{}' > wovtools/secrets/Adb_${TESTME}.json"

  tr_h1 "NEED TO FIX NEXT LINE"
  tr_run  "since wov-env does not work" "touch wovtools/config.json"
  tr_run "Adb env vars" "wov-env --context ${USECLUSTER}-${PROJ}-${TESTME} | grep Adb"
  tr_test 'create a Wov database instance but missing secrets' \
    "wov-db --context ${USECLUSTER}-${PROJ}-${TESTME} Adb --wdb-create" 203 -1

  tr_test 'clean up old Adb archive' "rm -Rf wovtools/db/archive/A*" 0 -1
  #tr_run  "list wdbs" "wov-db --context ${USECLUSTER}-${PROJ}-${TESTME} --lwdb"
  #tr_test "list wdbs" "wov-db --context ${USECLUSTER}-${PROJ}-${TESTME} --lwdb" 0 "Adb"
  tr_test 'clean up old Adb deltas'  "rm -Rf wovtools/db/*.deltas" 0 -1
  #tr_run  "list wdbs" "wov-db --context ${USECLUSTER}-${PROJ}-${TESTME} --lwdb"
  #tr_test "list wdbs" "wov-db --context ${USECLUSTER}-${PROJ}-${TESTME} --lwdb" 0 1 ""

  tr_test 'create a Wov database instance but missing WovDB files that identify a WovDB' \
    "wov-db --context ${USECLUSTER}-${PROJ}-${TESTME} --wdb-create" 204 -1

  tr_test 'create a Wov database instance but missing WovDB files' \
    "wov-db --context ${USECLUSTER}-${PROJ}-${TESTME} Adb --wdb-create" 201 -1

  tr_test 'clean up old Adb secrets' "rm -Rf wovtools/secrets/Adb*.json" 0 -1

  tr_test 'create a WovDataBase' "wov-init-wovdb --context ${USECLUSTER}-${PROJ}-${TESTME} Adb" 0 -1

  tr_test 'create a Wov database with correct context but bad DB' \
    "wov-db --context ${USECLUSTER}-test1-${TESTME} A --wdb-create" 201 -1
  tr_section '/wov-database-instance'
}


{
  tr_section 'wov-database-stop'

  tr_test 'stop any running db so we know it has correct user and password' \
    "wov-db --context ${USECLUSTER}-${PROJ}-${TESTME} Adb --stop " 0 -1

  tr_test 'start local postgres db' \
    "wov-db --context ${USECLUSTER}-${PROJ}-${TESTME} Adb --start" 0 -1

  tr_test 'info on db shows values' \
    "wov-db --context ${USECLUSTER}-${PROJ}-${TESTME} Adb --info" 0 -1

  tr_test 'info on db shows values (assumed db)' \
    "wov-db --context ${USECLUSTER}-${PROJ}-${TESTME} --info" 0 -1

  tr_section '/wov-database-stop'
}


{
  tr_section 'wov-db-create-and-init'
  tr_comment 'NOTE: requires a running local database from above section'

  tr_run "deinit WovDB" \
    "wov-db --context ${USECLUSTER}-test1-${TESTME} Adb -c \"DROP database wovtools\""

  tr_test 'Should be empty database' \
    "wov-db --context ${USECLUSTER}-test1-${TESTME} Adb -c \"\d\"" 0 1 "No relations found."

  tr_test 'Make sure connection works' \
    "wov-db --context ${USECLUSTER}-test1-${TESTME} Adb -c \"select 1\"" 0 -1

  tr_test 'Create and init Wov database' \
    "wov-db --context ${USECLUSTER}-test1-${TESTME} Adb --wdb-init" 0 -1

  tr_section '/wov-db-create-and-init'
}


{
  tr_section 'wov-db-cmds'

  tr_test 'Schema gets returned' \
    "wov-db --context ${USECLUSTER}-test1-${TESTME} Adb --schema | wc -l | tr -d \"[:space:]\"" 0 1 36

  tr_test 'Schema hash returned' \
    "wov-db --context ${USECLUSTER}-test1-${TESTME} Adb --schemahash " 0 1 "01ba4719c80b6fe911b091a7c05124b64eeece964e09c058ef8f9805daca546b"

  tr_test_skip 'Schema diff against 0 but no version' \
    "wov-db --context ${USECLUSTER}-test1-${TESTME} Adb --schema-diff 0" 1 1 "ERROR: no schema for database 'Adb', schema version '0'."


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

tr_tests_on
{
  tr_section "wov-db-helm"

  # this will detele and return when stateful set is gone, but pod will still exist and it retains its control on PVC
  tr_run  "turn off" "wov-db --context external:${USECLUSTER}-${PROJ}-${TESTME} Adb --stop"

  # deleting this now, will retain it until pod is stopped
  tr_run  "delete any persistent data since passwords will be different now" \
    "kubectl delete pvc --selector=release=\"adb-${TESTME}\""
  while [ true ]; do
    echo "...looking for pvc adb-${TESTME}"
    kubectl get pvc --selector="release=adb-${TESTME}" 2>&1 | grep "^No resources found in" > /dev/null ; Re=$?
    if [ $Re -eq 0 ]; then echo "...no more resources"; break; else echo "...waiting for pvc to delete"; sleep 1; fi
  done

  tr_run  "show namespace" "wov-ns"
  tr_run  "show pv, which should be going away" "kubectl get pv"
  tr_run  "show pvc" "kubectl describe pvc data-adb-${TESTME}-postgresql-0"
  tr_run  "show pv again, which should be going away" "kubectl get pv"

  tr_test "test" "wov-db --context external:${USECLUSTER}-${PROJ}-${TESTME} Adb --test" 1 1 "Not running"

  tr_test "info" "wov-db --context external:${USECLUSTER}-${PROJ}-${TESTME} Adb --info" 0 -1

  tr_test "start (can take a while)" "wov-db --context external:${USECLUSTER}-${PROJ}-${TESTME} Adb --start" 0 -1

  tr_test "test" "wov-db --context external:${USECLUSTER}-${PROJ}-${TESTME} Adb --test" 0 -1

  tr_test "sql command" "wov-db --context external:${USECLUSTER}-${PROJ}-${TESTME} Adb -c \"select 1\"" 0 -1

  tr_section "/wov-db-helm"
}


tr_popdir
tr_results
