#!/usr/bin/env bash

#export TESTUTIL_INITED="1"
#echo "...TESTUTIL inited"


function TestSetEcho() {
  export TESTUTIL_DOECHO=1
#  echo "...TESTUTIL Echoing"
}
function TestSetVerbose() {
  export TESTUTIL_DOECHO=1
#  echo "...TESTUTIL Echoing"
}
function TestSetQuiet() {
  export TESTUTIL_DOECHO=0
}
function TestSetNoEcho() {
  export TESTUTIL_DOECHO=0
}

function Test() {
  TESTUTIL_TEXT=$1
  if [ "$TESTUTIL_DOECHO" == "1" ]; then
    echo "TEST: $TESTUTIL_TEXT"
  fi
}

function TestError() {
  echo 
  echo 
  echo "***ERROR: $TESTUTIL_TEXT"
  echo
  echo "Compared: "
  echo "  '$1'"
  echo "  '$2'"
  echo
  exit 1
}

function TestEquals() {
#  echo "Compare: "
#  echo "  '$1'"
#  echo "  '$2'"
  if [ "$1" == "$2" ]; then
    a=1
  else
    TestError $1 $2
  fi
}

function TestNotEquals() {
  if [ "$1" != "$2" ]; then
    a=1
  else
    TestError $1 $2
  fi
}
