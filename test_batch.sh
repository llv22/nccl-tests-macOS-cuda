#!/bin/bash
if [ "$#" -ne "1" ]; then
    echo 'test_bash.sh: only support to enter trace parameters - log/normal'
    exit 1
fi

DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH:../nccl-osx/build/lib #load dynamic library from runtime
if [ "$1" == "log" ]; then
    echo "===begin all_reduce_perf test==="
    NCCL_DEBUG=INFO NCCL_SOCKET_IFNAME=lo NCCL_SOCKET_IFNAME=lo ./build/all_reduce_perf -b 8 -e 128M -f 2 -g 2 #fix socket issue, passed -> need to check shutdown logics
    echo ""
    echo "===begin all_gather_perf test==="
    NCCL_DEBUG=INFO NCCL_SOCKET_IFNAME=lo NCCL_SOCKET_IFNAME=lo ./build/all_gather_perf -b 8 -e 128M -f 2 -g 2 #passed
    echo ""
    echo "===begin reduce_perf test==="
    NCCL_DEBUG=INFO NCCL_SOCKET_IFNAME=lo NCCL_SOCKET_IFNAME=lo ./build/broadcast_perf -b 8 -e 128M -f 2 -g 2 #
    echo ""
    echo "===begin all_reduce_perf test==="
    NCCL_DEBUG=INFO NCCL_SOCKET_IFNAME=lo NCCL_SOCKET_IFNAME=lo ./build/reduce_perf -b 8 -e 128M -f 2 -g 2 #
    echo ""
    echo "===begin reduce_scatter_perf test==="
    NCCL_DEBUG=INFO NCCL_SOCKET_IFNAME=lo NCCL_SOCKET_IFNAME=lo ./build/reduce_scatter_perf -b 8 -e 128M -f 2 -g 2 #
    echo ""
elif [ "$1" == "normal" ]; then
    echo "===begin all_reduce_perf test==="
    NCCL_SOCKET_IFNAME=lo NCCL_SOCKET_IFNAME=lo ./build/all_reduce_perf -b 8 -e 128M -f 2 -g 2 #fix socket issue, passed -> need to check shutdown logics
    echo ""
    echo "===begin all_gather_perf test==="
    NCCL_SOCKET_IFNAME=lo NCCL_SOCKET_IFNAME=lo ./build/all_gather_perf -b 8 -e 128M -f 2 -g 2 #passed
    echo ""
    echo "===begin broadcast_perf test==="
    NCCL_SOCKET_IFNAME=lo NCCL_SOCKET_IFNAME=lo ./build/broadcast_perf -b 8 -e 128M -f 2 -g 2 #
    echo ""
    echo "===begin reduce_perf test==="
    NCCL_SOCKET_IFNAME=lo NCCL_SOCKET_IFNAME=lo ./build/reduce_perf -b 8 -e 128M -f 2 -g 2 #
    echo ""
    echo "===begin reduce_scatter_perf test==="
    NCCL_SOCKET_IFNAME=lo NCCL_SOCKET_IFNAME=lo ./build/reduce_scatter_perf -b 8 -e 128M -f 2 -g 2 #
    echo ""
else
    echo "please enter parameters - log/normal"
    exit 1
fi