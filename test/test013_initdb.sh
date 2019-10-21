#!/usr/bin/env bash
. /usr/local/bin/wtrunner

#tr_vverbose
tr_h1 "Init WovDataBase"
. test_common.sh
tcUseTestingContext

if [ ! -e "${PROJ}" ]; then echo "ERROR: project '${PROJ}' does not exist. Run the 'test011_init.sh' test to create it."; exit 1; fi
tr_dir "${PROJ}"
export PATH=$PATH:/usr/local/bin/wovlib
. wov-env-logging
. wov-env-loader

{
  tr_section 'initfortests'
  tr_protectfile "wovtools/config.json" 
  #tr_protectfile "wovtools/myconfig.json"
  tr_run 'set origin to here' 'wov-env --set-origin here'
  rm -Rf wovtools/secrets/A*db.json
  rm -Rf wovtools/db/archive/A*
  # tcUseTestingContext

  tr_run "remove entries from config for database in dev" \
    "jq -r 'del( .secrets.dev[] | select( . == \"Adb.json\" or . == \"Adb_dev.json\" ) )' wovtools/config.json > wovtools/config.json.1 ; mv wovtools/config.json.1 wovtools/config.json"
  tr_run "remove entries from config for database in prod" \
    "jq -r 'del( .secrets.prod[] | select( . == \"Adb.json\" or . == \"Adb_prod.json\" ) )' wovtools/config.json > wovtools/config.json.1 ; mv wovtools/config.json.1 wovtools/config.json"
  tr_run "remove entries from myconfig for database in prod" \
    "jq -r 'del( .secrets.${TESTME}[] | select( . == \"Adb.json\" or . == \"Adb_${TESTME}.json\" ) )' wovtools/myconfig.json > wovtools/myconfig.json.1 ; mv wovtools/myconfig.json.1 wovtools/myconfig.json"

  # tr_run "now it is: " "cat wovtools/config.json"
  tr_test "ensure wovdb not in dev secrets"  "jq -r '.secrets.dev[]' wovtools/config.json | grep Adb.json " 1 -1 
  tr_test "ensure wovdb not in prod secrets" "jq -r '.secrets.prod[]' wovtools/config.json | grep Adb.json " 1 -1 
  tr_test "ensure wovdb not in me secrets"   "jq -r '.secrets.${TESTME}[]' wovtools/myconfig.json | grep Adb.json " 1 -1 
  tr_section '/initfortests'
}

{
  tr_section 'initdb'

  tr_h1 'wov-init-wovdb'

  tr_test 'No name' "wov-init-wovdb" 101 -1 

  tr_test 'No "db" ending' "wov-init-wovdb A" 103 -1 
  
  # kubectl config current-context
  # cat wovtools/config.json
  # cat wovtools/myconfig.json
  # cat ~/.wovtools/config
  # wov-init-wovdb Adb --context "${USECLUSTER}-${PROJ}-${TESTME}" Adb
  # cat wovtools/myconfig.json
  # exit 1
  tr_test 'create a WovDataBase' "wov-init-wovdb --context \"${USECLUSTER}-${PROJ}-${TESTME}\" Adb" 0 -1 

  wov-env -e
  tr_test "should list it now" "wov-db -lwdb" 0 1 "Adb"

  tr_vverbose
  tr_test 'existing database' "wov-init-wovdb --context \"${USECLUSTER}-${PROJ}-${TESTME}\" Adb | grep '...existing WovDataBase' | wc -l | tr -d '[:space:]'" 0 1 2

#  tr_run "remove entries from config for database in dev" \
#    "jq -r 'del( .secrets.dev[] | select( . == \"Adb.json\" or . == \"Adb_dev.json\" ) )' wovtools/config.json > wovtools/config.json.1 ; mv wovtools/config.json.1 wovtools/config.json"
#  tr_run "remove entries from config for database in prod" \
#    "jq -r 'del( .secrets.prod[] | select( . == \"Adb.json\" or . == \"Adb_prod.json\" ) )' wovtools/config.json > wovtools/config.json.1 ; mv wovtools/config.json.1 wovtools/config.json"
#  tr_run "remove entries from myconfig for database in prod" \
#    "jq -r 'del( .secrets.${TESTME}[] | select( . == \"Adb.json\" or . == \"Adb_${TESTME}.json\" ) )' wovtools/myconfig.json > wovtools/myconfig.json.1 ; mv wovtools/myconfig.json.1 wovtools/myconfig.json"
#
#  # tr_run "now it is: " "cat wovtools/config.json"
#  tr_test "ensure wovdb not in dev secrets"  "jq -r '.secrets.dev[]' wovtools/config.json | grep Adb.json " 1 -1 
#  tr_test "ensure wovdb not in prod secrets" "jq -r '.secrets.prod[]' wovtools/config.json | grep Adb.json " 1 -1 
#  tr_test "ensure wovdb not in me secrets"   "jq -r '.secrets.${TESTME}[]' wovtools/myconfig.json | grep Adb.json " 1 -1 

#  wov-init-wovdb --context wov-aws-va-grape-alywan-dev Adb
  tr_test 'existing database but not in secrets' "wov-init-wovdb --context wov-aws-va-grape-alywan-dev Adb | grep '...existing WovDataBase'|  wc -l  | tr -d '[:space:]'" 0 1 2
  tr_test "ensure wovdb back in secrets" "jq -r '.secrets.dev[]' wovtools/config.json | grep Adb.json " 0 -1 
  tr_test "ensure wovdb back in secrets" "jq -r '.secrets.dev[]' wovtools/config.json | grep Adb_dev.json " 0 -1 
  tr_test "secrets should have this" "jq -r '.secrets.prod[]' wovtools/config.json | grep Adb.json" 0 1 "Adb.json"
  tr_test "secrets should have this" "jq -r '.secrets.prod[]' wovtools/config.json | grep Adb_prod.json" 0 1 "Adb_prod.json"
  tr_test "secrets should have this" "jq -r '.secrets.${TESTME}[]' wovtools/myconfig.json | grep Adb.json" 0 1 "Adb.json"
  tr_test "secrets should have this" "jq -r '.secrets.${TESTME}[]' wovtools/myconfig.json | grep Adb_${TESTME}.json" 0 1 "Adb_${TESTME}.json"


  tr_section '/initdb'
}

{
  tr_section "dbcheckins"

  tr_test "add db secrets " \
    "git -C wovtools/secrets add 'Adb.json' 'Adb_${TESTME}.json' 'Adb_dev.json' 'Adb_prod.json'" \
    0 -1

  tr_run "secrets checkin" \
    "git -C wovtools/secrets commit -a -m 'test013 db secrets'; "`
   `"git -C wovtools/secrets push"

  tr_run "dba checkin" \
    "git -C wovtools/db/archive add 'Adb.json'; "`
   `"git -C wovtools/db/archive commit -a -m 'test013 db wovdb def'; "`
   `"git -C wovtools/db/archive push"

  tr_run "code checkin (wovtools/config.json now has Adb entries in dev/prod)" \
    "git commit -a -m 'test013 db wovdb def'; "`
   `"git push"

   . wov-env-common

   tr_test "code: check git is checked in and pushed" "cGit_CheckFull ." 0 -1
   tr_test "sea: check git is checked in and pushed" "cGit_CheckFull wovtools/secrets" 0 -1
   tr_test "dba: check git is checked in and pushed" "cGit_CheckFull wovtools/db/archive" 0 -1
   tr_test "dsa: check git is checked in and pushed" "cGit_CheckFull wovtools/ds/const" 0 -1

  tr_section "/dbcheckins"
}

tr_popdir
tr_results
