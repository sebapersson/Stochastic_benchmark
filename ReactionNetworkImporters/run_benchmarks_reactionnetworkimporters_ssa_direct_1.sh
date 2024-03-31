#!/bin/bash

#SBATCH -o ../Results/ReactionNetworkImporters/Logs/run_benchmarks_reactionnetworkimporters_ssa_direct_1.log
#SBATCH -N 1  
#SBATCH --ntasks=1  
#SBATCH --cpus-per-task=1
#SBATCH --exclusive=user
#SBATCH --mem-per-cpu=192000MB

JULIA_THREADS_TO_USE=1
run_julia="julia"

echo "Starts benchmark runs on the multistate model."
time ${run_julia} --threads $JULIA_THREADS_TO_USE reactionnetworkimporters_make_benchmark.jl multistate Direct 1 5 9

echo "Starts benchmark runs on the multisite2 model."
time ${run_julia} --threads $JULIA_THREADS_TO_USE reactionnetworkimporters_make_benchmark.jl multisite2 Direct 1 4 7

echo "Starts benchmark runs on the egfr_net model."
time ${run_julia} --threads $JULIA_THREADS_TO_USE reactionnetworkimporters_make_benchmark.jl egfr_net Direct 1 2 4

echo "Starts benchmark runs on the fceri_gamma2 model."
time ${run_julia} --threads $JULIA_THREADS_TO_USE reactionnetworkimporters_make_benchmark.jl fceri_gamma2 Direct 1 2 4