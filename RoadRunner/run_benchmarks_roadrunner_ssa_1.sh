#!/bin/bash

#SBATCH -o ../Results/RoadRunner/Logs/run_benchmarks_roadrunner_ssa_1.log
#SBATCH -N 1  
#SBATCH --ntasks=1  
#SBATCH --cpus-per-task=1
#SBATCH --exclusive=user
#SBATCH --mem-per-cpu=192000MB

JULIA_THREADS_TO_USE=1
run_julia="/home/sebpe/julia-1.10.2/bin/julia"

echo "Starts benchmark runs on the multistate model."
time ${run_julia}  --threads $JULIA_THREADS_TO_USE roadrunner_make_benchmark.jl multistate SSA 1 5 9

echo "Starts benchmark runs on the multisite2 model."
time ${run_julia}  --threads $JULIA_THREADS_TO_USE roadrunner_make_benchmark.jl multisite2 SSA 1 4 7

echo "Starts benchmark runs on the egfr_net model."
time ${run_julia}  --threads $JULIA_THREADS_TO_USE roadrunner_make_benchmark.jl egfr_net SSA 1 2 4