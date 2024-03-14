#!/bin/bash

# To enable Python packages in Julia
eval "$(conda shell.bash hook)"
conda activate Stochastic_benchmark

echo "Starts benchmark runs on the BCR model."
time python pysb_make_benchmarks.py BCR nfsim 3.398 4.204 2 2