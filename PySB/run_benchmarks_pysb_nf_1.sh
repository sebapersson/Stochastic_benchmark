#!/bin/bash

#SBATCH -o ../Results/PySB/Logs/run_benchmarks_pysb_nf_1.log
#SBATCH -N 1  
#SBATCH --ntasks=1  
#SBATCH --cpus-per-task=1
#SBATCH --exclusive=user
#SBATCH --mem-per-cpu=192000MB

# To enable Python packages in Julia
eval "$(conda shell.bash hook)"
conda activate Stochastic_benchmark

echo "Starts benchmark runs on the multistate model."
time python pysb_make_benchmarks.py multistate nf 1 5 9 10

echo "Starts benchmark runs on the multisite2 model."
time python pysb_make_benchmarks.py multisite2 nf 1 4 7 10

echo "Starts benchmark runs on the egfr_net model."
time python pysb_make_benchmarks.py egfr_net nf 1 3 7 10

echo "Starts benchmark runs on the fceri_gamma2 model."
time python pysb_make_benchmarks.py fceri_gamma2 nf 1 3 4 5