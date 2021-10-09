﻿#!/bin/bash
if [ "$#" -ne "1" ]; then
    echo 'test_bash.sh: only support to enter trace parameters - log/normal'
    exit 1
fi

DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH:../nccl-osx/build/lib #load dynamic library from runtime
allScripts=("sendrecv_perf" "scatter_perf" "hypercube_perf" "alltoall_perf" "all_reduce_perf" "all_gather_perf" "broadcast_perf" "reduce_perf" "reduce_scatter_perf") #refer to https://opensource.com/article/18/5/you-dont-know-bash-intro-bash-arrays
if [ "$1" == "log" ]; then
    for t in ${allScripts[@]}; do
        echo "===begin $t test==="
        NCCL_TOPO_DUMP_FILE=./topo.xml NCCL_DEBUG=INFO ./build/$t -b 8 -e 128M -f 2 -g 2 #fix socket issue, passed -> need to check shutdown logics
        echo ""
    done
elif [ "$1" == "normal" ]; then
    for t in ${allScripts[@]}; do
        echo "===begin $t test==="
        ./build/$t -b 8 -e 128M -f 2 -g 2 #fix socket issue, passed -> need to check shutdown logics
        echo ""
    done
else
    echo "please enter parameters - log/normal"
    exit 1
fi