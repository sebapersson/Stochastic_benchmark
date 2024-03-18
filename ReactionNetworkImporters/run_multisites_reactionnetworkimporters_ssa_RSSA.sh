#!/bin/bash

#SBATCH -o ../Results/ReactionNetworkImporters/Logs/run_multisites_reactionnetworkimporters_ssa_RSSA.log
#SBATCH -N 1  
#SBATCH --ntasks=1  
#SBATCH --cpus-per-task=1
#SBATCH --exclusive=user
#SBATCH --mem-per-cpu=192000MB

JULIA_THREADS_TO_USE=1
run_julia="julia"

for i in {1..7}
do
    if [[ "$i" == '2' ]]; then
        continue
    fi
    echo "Starts benchmark runs on the multisite model nr ${i}"
    model_run="multisite${i}"
    time ${run_julia} --threads $JULIA_THREADS_TO_USE reactionnetworkimporters_make_benchmark.jl ${model_run} RSSA 1 3 3
done