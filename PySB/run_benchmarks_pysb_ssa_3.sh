#!/bin/bash

# To enable Python packages in Julia
eval "$(conda shell.bash hook)"
conda activate Stochastic_benchmark

echo "Starts benchmark runs on the fceri_gamma2 model."
time python pysb_make_benchmarks.py fceri_gamma2 nfsim 1 3 4 5
