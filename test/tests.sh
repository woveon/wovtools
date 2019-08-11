#!/usr/bin/env bash

# NOTE: assumes test1 is a project

if [ ! -e test1 ]; then
  echo "ERROR: tests.sh expects test1 to be a Wovoen project. Run 'test1.sh'."
  exit 1
fi

# Load test runner
. /usr/local/bin/wtrunner


# tr_run test0.sh
# tr_run test1.sh
test_wov-aws
tr_runfile test2.sh
