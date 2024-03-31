#!/bin/bash

#SBATCH -o ../Results/ReactionNetworkImporters/Logs/run_benchmarks_reactionnetworkimporters_ssa_sortingdirect_2.log
#SBATCH -N 1  
#SBATCH --ntasks=1  
#SBATCH --cpus-per-task=1
#SBATCH --exclusive=user
#SBATCH --mem-per-cpu=192000MB

JULIA_THREADS_TO_USE=1
run_julia="julia"

echo "Starts benchmark runs on the BCR model."
time ${run_julia} --threads $JULIA_THREADS_TO_USE reactionnetworkimporters_make_benchmark.jl BCR SortingDirect 3.398 5.01 3
