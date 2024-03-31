#!/bin/bash

#SBATCH -o ../Results/SBMLImporter/Logs/run_benchmarks_sbmlimporter_ssa_RSSA_1.log
#SBATCH -N 1  
#SBATCH --ntasks=1  
#SBATCH --cpus-per-task=1
#SBATCH --exclusive=user
#SBATCH --mem-per-cpu=192000MB

JULIA_THREADS_TO_USE=1
run_julia="julia"

echo "Starts benchmark runs on the multistate model."
time ${run_julia} --threads $JULIA_THREADS_TO_USE sbmlimporter_make_benchmark.jl multistate RSSA 1 5 9

echo "Starts benchmark runs on the multisite2 model."
time ${run_julia} --threads $JULIA_THREADS_TO_USE sbmlimporter_make_benchmark.jl multisite2 RSSA 1 4 7

echo "Starts benchmark runs on the egfr_net model."
time ${run_julia} --threads $JULIA_THREADS_TO_USE sbmlimporter_make_benchmark.jl egfr_net RSSA 1 3 7

echo "Starts benchmark runs on the fceri_gamma2 model."
time ${run_julia} --threads $JULIA_THREADS_TO_USE sbmlimporter_make_benchmark.jl fceri_gamma2 RSSA 1 3 7