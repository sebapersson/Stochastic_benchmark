#!/bin/bash

#SBATCH -o ../Results/SBMLImporter/Logs/run_multisites_sbmlimporter_ssa_RSSACR.log
#SBATCH -N 1  
#SBATCH --ntasks=1  
#SBATCH --cpus-per-task=1
#SBATCH --exclusive=user
#SBATCH --mem-per-cpu=192000MB

JULIA_THREADS_TO_USE=1
run_julia="julia"

for i in {1..6}
do
    if [[ "$i" == '2' ]]; then
        continue
    fi
    echo "Starts benchmark runs on the multisite model nr ${i}"
    model_run="multisite${i}"
    time ${run_julia} --threads $JULIA_THREADS_TO_USE sbmlimporter_make_benchmark.jl ${model_run} RSSACR 1 3 3
done