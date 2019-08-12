#!/usr/bin/env bash
. /usr/local/bin/wtrunner

tr_runfile test001_init.sh
tr_runfile test002_wov-env.sh
tr_runfile test010_wov-db.sh
tr_runfile test030_wov-push-container.sh
tr_runfile test031_wov-push-k8s.sh
tr_runfile test032_wov-push-db.sh
tr_runfile test080_wov-aws.sh
