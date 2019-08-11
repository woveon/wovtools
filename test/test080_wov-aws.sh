#!/usr/bin/env bash


. ./trunner.sh

tr_h2 'wov-aws'

tr_vverbose
tr_dir test1
tr_test "Convert Region Code" 'wov-aws --convertrc va' 0 1 "us-east-1"

tr_results
