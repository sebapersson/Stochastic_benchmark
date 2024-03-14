#!/bin/bash

#SBATCH -o ../Results/PySB/Logs/run_benchmarks_pysb_ssa_1.log
#SBATCH -N 1  
#SBATCH --ntasks=1  
#SBATCH --cpus-per-task=1
#SBATCH --exclusive=user
#SBATCH --mem-per-cpu=192000MB

# To enable Python packages in Julia
eval "$(conda shell.bash hook)"
conda activate Stochastic_benchmark

echo "Starts benchmark runs on the BCR model."
time python pysb_make_benchmarks.py BCR ssa 3.398 4.204 2 2