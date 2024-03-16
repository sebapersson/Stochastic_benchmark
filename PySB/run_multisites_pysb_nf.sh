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

for i in {1..7}
do
    if [[ "$i" == '2' ]]; then
        continue
    fi
    echo "Starts benchmark runs on the multisite model nr ${i}"
    model_run="multisite${i}"
    time python pysb_make_benchmarks.py ${model_run} nf 1 3 3 10
done