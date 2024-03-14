#!/bin/bash

#SBATCH -o ../Results/Catalyst/Logs/run_benchmarks_catalyst_ssa_sortingdirect.log
#SBATCH -N 1  
#SBATCH --ntasks=1  
#SBATCH --cpus-per-task=1
#SBATCH --exclusive=user
#SBATCH --mem-per-cpu=192000MB

JULIA_THREADS_TO_USE=1
run_julia="/home/sebpe/julia-1.10.2/bin/julia"

echo "Starts benchmark runs on the multistate model."
time ${run_julia} --threads $JULIA_THREADS_TO_USE catalyst_make_benchmark.jl multistate SortingDirect 1 5 9

echo "Starts benchmark runs on the multisite2 model."
time ${run_julia} --threads $JULIA_THREADS_TO_USE catalyst_make_benchmark.jl multisite2 SortingDirect 1 5 9

echo "Starts benchmark runs on the egfr_net model."
time ${run_julia} --threads $JULIA_THREADS_TO_USE catalyst_make_benchmark.jl egfr_net SortingDirect 1 3 7

echo "Starts benchmark runs on the BCR model."
time ${run_julia} --threads $JULIA_THREADS_TO_USE catalyst_make_benchmark.jl BCR SortingDirect 3.398 5.01 3

echo "Starts benchmark runs on the fceri_gamma2 model."
time ${run_julia} --threads $JULIA_THREADS_TO_USE catalyst_make_benchmark.jl fceri_gamma2 SortingDirect 1 3 7
