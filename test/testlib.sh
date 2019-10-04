#!/usr/bin/env bash


## Useful functionality to assist with tests
#
#_tr_protectedfiles=()
#_tr_protectext="`date +%s`.$$"      # date and process number
#_tr_protecteddir="`realpath ./wtrunnerprotectedfiles`"
#
#function tr_protectfile()
#{
#  local fullfile=
#  local basefile=
#
#  # Make dir if needed
#  if [ ! -e ${_tr_protecteddir} ]; then 
#    mkdir ${_tr_protecteddir}
#    if [ $? -ne 0 ]; then echo "ERROR: failed to create directory for protected files at '${_tr_protecteddir}'."; exit 1; fi
#  fi
#
#  if [ -e "${1}" ]; then 
#    fullfile=`realpath "${1}"`
#    basefile=`basename "${1}"`
#    echo "...protecting file '${basefile}' : ${fullfile}"
#    cp "${fullfile}" "${_tr_protecteddir}/${basefile}.${_tr_protectext}"
#    _tr_protectedfiles+=( "${fullfile}" )
#  fi
#
#}
#
#function tr_onfinish()
#{
#  # Protected Files
#  for f in ${_tr_protectedfiles}; do
#    local basefile=`basename "${f}"`
#    echo "...replacing original file '${basefile}' : ${f}"
#    mv "${_tr_protecteddir}/${basefile}.${_tr_protectext}" "${f}"
#  done
#  _tr_protectedfiles=()
#
#}
#trap tr_onfinish EXIT


