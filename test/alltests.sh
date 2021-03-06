#!/usr/bin/env bash
. /usr/local/bin/wtrunner


# fail.sh is literally a fail test case... useful for testing fails
# tr_runfile fail.sh

tr_h1 "Test Parts of Init"
tr_runfile test001_globalconfig.sh
tr_runfile test002_pathext.sh
tr_runfile test004_projconfig.sh

# NOTE: test005 fails. Need to update it after all changes to dir structures and naming. Redundant with 011 test so have not fixed yet.
# tr_runfile test005_gitinit.sh


tr_h1 "Init Tests"
tr_runfile test011_init.sh

# all depend on test1 created above
{
  tr_runfile test012_initms.sh
  tr_runfile test013_initdb.sh
  # TODO tr_runfile test013_initcluster.sh
  tr_runfile test014_initstage.sh


  tr_h1 "General Command Tests"
  tr_runfile test101_wov-env.sh
  tr_runfile test110_wov-db.sh
  tr_runfile test120_wov-checkout.sh


  tr_h1 "Push Commands Tests"
  tr_runfile test230_wov-push-container.sh
  tr_runfile test231_wov-push-k8s.sh
  tr_runfile test232_wov-push-db.sh


  tr_h1 "Provider Tests"
  tr_runfile test910_wov-aws.sh
}
