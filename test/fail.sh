#!/usr/bin/env bash

. /usr/local/bin/wtrunner


tr_protectcmds <<EOF
echo "Hi pre protect"
echo "hi again pre"
EOF
tr_protectcmds_post <<EOF
echo "Hi post protect"
echo "hi again post"
EOF

tr_test "fail" "exit 1" 0 -1
