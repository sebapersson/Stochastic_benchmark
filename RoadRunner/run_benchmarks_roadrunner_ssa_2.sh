#!/bin/bash

#SBATCH -o ../Results/PySB/Logs/run_benchmarks_roadrunner_ssa_2.log
#SBATCH -N 1  
#SBATCH --ntasks=1  
#SBATCH --cpus-per-task=1
#SBATCH --exclusive=user
#SBATCH --mem-per-cpu=192000MB

JULIA_THREADS_TO_USE=1
run_julia="/home/sebpe/julia-1.10.2/bin/julia"

echo "Starts benchmark runs on the BCR model."
time ${run_julia} --threads $JULIA_THREADS_TO_USE roadrunner_make_benchmark.jl BCR SSA 3.398 4.204 2
