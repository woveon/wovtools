#!/usr/bin/env bash
. /usr/local/bin/wtrunner

#tr_vverbose
tr_h1 "Init WovDataBase"

PROJ=test1

{
  tr_section 'initfortests'
  if [ ! -e "${PROJ}" ]; then echo "ERROR: project '${PROJ}' does not exist. Run the 'test011_init.sh' test to create it."; exit 1; fi
  tr_dir "${PROJ}"
  tr_protectfile "wovtools/config.json" 
  tr_protectfile "wovtools/myconfig.json"
  tr_run 'set origin to here' 'wov-env --set-origin here'
  rm -Rf wovtools/secrets/A*db.json
  rm -Rf wovtools/db/archive/A*
  tr_section '/initfortests'
}

{
  tr_section 'initdb'

  tr_h1 'wov-init-wovdb'

  tr_test 'No name' "wov-init-wovdb" 101 -1 

  tr_test 'No "db" ending' "wov-init-wovdb A" 103 -1 
  
  tr_test 'create a WovDataBase' "wov-init-wovdb Adb" 0 -1 

  tr_test "should list it now" "wov-db -lwdb" 0 1 "Adb"

  tr_vverbose
  tr_test 'existing database' "wov-init-wovdb Adb | grep 'WARNING' > /dev/null && echo 1" 0 1 1

  tr_run "remove entries from myconfig for database" "jq -r 'del( .secrets.dev[] | select( . == \"Adb.json\" or . == \"Adb_dev.json\" ) )' wovtools/config.json > wovtools/config.json.1 ; mv wovtools/config.json.1 wovtools/config.json"
  tr_test "ensure wovdb not in secrets" "jq -r '.secrets.dev[]' wovtools/config.json | grep Adb.json " 1 -1 
  tr_test 'existing database but not in secrets' "wov-init-wovdb Adb | grep 'WARNING'" 0 -1
  tr_test "ensure wovdb back in secrets" "jq -r '.secrets.dev[]' wovtools/config.json | grep Adb.json " 0 -1 
  tr_test "secrets should have this" "jq -r '.secrets.prod[]' wovtools/config.json | grep Adb.json" 0 1 "Adb.json"


  tr_section '/initdb'
}

tr_popdir
tr_results
