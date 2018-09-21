#!/usr/bin/env bash

echo "data"
kubectl logs -f --tail 1000 `wov-p apidata` &
L1=$!
echo "hal"
kubectl logs -f --tail 1000 `wov-p apihal` &
L2=$!
kubectl logs -f --tail 1000 `wov-p apirest` &
L3=$!
kubectl logs -f --tail 1000 `wov-p apirest2` &
L4=$!

wait $L1 $L2 $L3 $L4
