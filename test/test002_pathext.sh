#!/usr/bin/env bash
. /usr/local/bin/wtrunner

tr_h1 "Test Path Extention Naming"

export PATH=$PATH:/usr/local/bin/wovlib
. wov-env-common

{

  M=mp
  P=p
  MSC=msc
  ME=me

  tr_test "ra xx" "WovPathExt ra xx ${M} ${P} ${ME}" 1 -1
  tr_test "ra se" "WovPathExt ra se ${M} ${P} ${ME}" 0 1 "mp_sea_me"
  tr_test "ra db" "WovPathExt ra db ${M} ${P} ${ME}" 0 1 "mp_p_dba"
  tr_test "ra ds" "WovPathExt ra ds ${M} ${P} ${ME}" 0 1 "mp_dsa"

  tr_test "la xx" "WovPathExt la xx ${M} ${P} ${ME}" 1 -1
  tr_test "la se" "WovPathExt la se ${M} ${P} ${ME}" 0 1 "mp_sea"
  tr_test "la db" "WovPathExt la db ${M} ${P} ${ME}" 0 1 "mp_p_dba"
  tr_test "la ds" "WovPathExt la ds ${M} ${P} ${ME}" 0 1 "mp_dsa"

  tr_test "pr single" "WovPathExt pr ${M} ${P} ${MSC}" 0 1 "mp_p_pmsc"
  tr_test "pr many"   "WovPathExt pr ${M} ${P}"        0 1 "mp_p"

  tr_test "pp single" "WovPathExt pp ${M} ${P} ${MSC}" 0 1 "mp/p_pmsc"
  tr_test "pp many"   "WovPathExt pp ${M} ${P}"        0 1 "mp/p"

}

tr_results
