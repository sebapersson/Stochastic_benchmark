#!/bin/bash

# To enable Python packages in Julia
eval "$(conda shell.bash hook)"
conda activate Stochastic_benchmark

echo "Starts benchmark runs on the multistate model."
time python pysb_make_benchmarks.py multistate nfsim 1 5 9 10

echo "Starts benchmark runs on the multisite2 model."
time python pysb_make_benchmarks.py multisite2 nfsim 1 4 7 10

echo "Starts benchmark runs on the egfr_net model."
time python pysb_make_benchmarks.py egfr_net nfsim 1 2 4 10