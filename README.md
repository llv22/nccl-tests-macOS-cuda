# NCCL on macOS Tests

These tests check both the performance and the correctness of NCCL operations. They can be compiled against [NCCL](http://github.com/nvidia/nccl)

In order to make library and nccl-test compatible, each nccl library version will be unique mapped to nccl-test on macOS version. When you start your work from my version, please also keep in mind.

* [nccl-2.5.7-1-release](https://github.com/llv22/nccl-osx/tree/dev-2.5.7-for-jax) should be tested by [nccl-tests-v2.0.0 on mac](https://github.com/llv22/nccl-tests-macOS-cuda/tree/v2.0.0-built).

## Build

To build the tests, just type `make`.

If CUDA is not installed in /usr/local/cuda, you may specify CUDA\_HOME. Similarly, if NCCL is not installed in /usr, you may specify NCCL\_HOME.

```shell
make CUDA_HOME=/path/to/cuda NCCL_HOME=/path/to/nccl
```

NCCL tests rely on MPI to work on multiple processes, hence multiple nodes. If you want to compile the tests with MPI support, you need to set MPI=1 and set MPI\_HOME to the path where MPI is installed.

```shell
make MPI=1 MPI_HOME=/path/to/mpi CUDA_HOME=/path/to/cuda NCCL_HOME=/path/to/nccl
```

## Usage

NCCL tests can run on multiple processes, multiple threads, and multiple CUDA devices per thread. The number of process is managed by MPI and is therefore not passed to the tests as argument. The total number of ranks (=CUDA devices) will be equal to (number of processes)\*(number of threads)\*(number of gpus per thread).

### Quick examples

Run on 8 GPUs (`-g 8`), scanning from 8 Bytes to 128MBytes :

```shell
./build/all_reduce_perf -b 8 -e 128M -f 2 -g 8
```

Run with MPI on 40 processes (potentially on multiple nodes) with 4 GPUs each, disabling checks :

```shell
mpirun -np 40 ./build/all_reduce_perf -b 8 -e 128M -f 2 -g 4 -c 0
```

### Performance

See the [Performance](doc/PERFORMANCE.md) page for explanation about numbers, and in particular the "busbw" column.

### Arguments

All tests support the same set of arguments :

* Number of GPUs
  * `-t,--nthreads <num threads>` number of threads per process. Default : 1.
  * `-g,--ngpus <gpus per thread>` number of gpus per thread. Default : 1.
* Sizes to scan
  * `-b,--minbytes <min size in bytes>` minimum size to start with. Default : 32M.
  * `-e,--maxbytes <max size in bytes>` maximum size to end at. Default : 32M.
  * Increments can be either fixed or a multiplication factor. Only one of those should be used
    * `-i,--stepbytes <increment size>` fixed increment between sizes. Default : (max-min)/10.
    * `-f,--stepfactor <increment factor>` multiplication factor between sizes. Default : disabled.
* NCCL operations arguments
  * `-o,--op <sum/prod/min/max/all>` Specify which reduction operation to perform. Only relevant for reduction operations like Allreduce, Reduce or ReduceScatter. Default : Sum.
  * `-d,--datatype <nccltype/all>` Specify which datatype to use. Default : Float.
  * `-r,--root <root/all>` Specify which root to use. Only for operations with a root like broadcast or reduce. Default : 0.
* Performance
  * `-n,--iters <iteration count>` number of iterations. Default : 20.
  * `-w,--warmup_iters <warmup iteration count>` number of warmup iterations (not timed). Default : 5.
* Test operation
  * `-p,--parallel_init <0/1>` use threads to initialize NCCL in parallel. Default : 0.
  * `-c,--check <0/1>` check correctness of results. This can be quite slow on large numbers of GPUs. Default : 1.
  * `-z,--blocking <0/1>` Make NCCL collective blocking, i.e. have CPUs wait and sync after each collective. Default : 0.

## Copyright

NCCL tests are provided under the BSD licence. All source code and accompanying documentation is copyright (c) 2016-2019, NVIDIA CORPORATION. All rights reserved.

## macOS version

1. generation of start example:

add ```export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/i058959/dl-frameworks/nccl/nccl-2.5.7/lib``` before running and do overwriting the default nccl home in order to test your built libraries

```bash
make NCCL_HOME=/Users/llv23/Documents/05_machine_learning/dl_gpu_mac/drivers_mac/nccl-osx/nccl-2.5.7 CXX=clang++ -j12  
make NCCL_HOME=/Users/llv23/Documents/05_machine_learning/dl_gpu_mac/drivers_mac/nccl-osx/build CXX=clang++ -j12  
./build/all_reduce_perf -b 8 -e 128M -f 2 -g 2
./build/all_gather_perf -b 8 -e 128M -f 2 -g 2
./build/broadcast_perf -b 8 -e 128M -f 2 -g 2
./build/reduce_perf -b 8 -e 128M -f 2 -g 2
./build/reduce_scatter_perf -b 8 -e 128M -f 2 -g 2
```

loading with INFO trace, via the following commands:

```bash
export DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH:~/Documents/05_machine_learning/dl_gpu_mac/drivers_mac/nccl-osx/build/lib #load dynamic library from runtime
NCCL_DEBUG=INFO ./build/all_reduce_perf -b 8 -e 128M -f 2 -g 2
NCCL_DEBUG=INFO ./build/all_gather_perf -b 8 -e 128M -f 2 -g 2
NCCL_DEBUG=INFO ./build/broadcast_perf -b 8 -e 128M -f 2 -g 2
NCCL_DEBUG=INFO ./build/reduce_perf -b 8 -e 128M -f 2 -g 2
NCCL_DEBUG=INFO ./build/reduce_scatter_perf -b 8 -e 128M -f 2 -g 2
```

enabling trace, refer to <https://github.com/NVIDIA/nccl/issues/197>:

```bash
NCCL_DEBUG=INFO NCCL_DEBUG_FLAGS=TRACE ./build/all_reduce_perf -b 8 -e 128M -f 2 -g 2
```

Issue: 1, library out of sync, refer to <http://sd.jtimothyking.com/2018/07/26/stub-file-and-library-file-out-of-sync/>  

```bash
sudo mv /Library/Developer/CommandLineTools /Library/Developer/CommandLineTools.old
xcode-select --install
sudo rm -rf /Library/Developer/CommandLineTools.old
```

Issue: 2, create network, refer to <https://github.com/NVIDIA/nccl/issues/352>

```bash
export DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH:~/Documents/05_machine_learning/dl_gpu_mac/drivers_mac/nccl-osx/build/lib #load dynamic library from runtime
NCCL_DEBUG=INFO NCCL_SOCKET_IFNAME=lo ./build/all_reduce_perf -b 8 -e 128M -f 2 -g 2 #fix socket issue, passed -> need to check shutdown logics
NCCL_DEBUG=INFO NCCL_SOCKET_IFNAME=lo ./build/all_gather_perf -b 8 -e 128M -f 2 -g 2 #passed
NCCL_DEBUG=INFO NCCL_SOCKET_IFNAME=lo ./build/broadcast_perf -b 8 -e 128M -f 2 -g 2 #
NCCL_DEBUG=INFO NCCL_SOCKET_IFNAME=lo ./build/reduce_perf -b 8 -e 128M -f 2 -g 2 #
NCCL_DEBUG=INFO NCCL_SOCKET_IFNAME=lo ./build/reduce_scatter_perf -b 8 -e 128M -f 2 -g 2 #
```

```bash
export DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH:~/Documents/05_machine_learning/dl_gpu_mac/drivers_mac/nccl-osx/build/lib #load dynamic library from runtime
NCCL_DEBUG=INFO NCCL_SOCKET_FAMILY=AF_INET ./build/all_reduce_perf -b 8 -e 128M -f 2 -g 2 #fix socket issue, passed -> need to check shutdown logics
NCCL_DEBUG=INFO NCCL_SOCKET_FAMILY=AF_INET6 ./build/all_reduce_perf -b 8 -e 128M -f 2 -g 2 #fix socket issue, passed -> need to check shutdown logics
```
