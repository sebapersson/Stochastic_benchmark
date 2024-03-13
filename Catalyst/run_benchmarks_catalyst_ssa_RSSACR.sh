#!/bin/bash

JULIA_THREADS_TO_USE=1
run_julia="/home/sebpe/julia-1.10.2/bin/julia"

echo "Starts benchmark runs on the multistate model."
time ${run_julia} --threads $JULIA_THREADS_TO_USE catalyst_make_benchmark.jl multistate RSSACR 1 5 9

echo "Starts benchmark runs on the multisite2 model."
time ${run_julia} --threads $JULIA_THREADS_TO_USE catalyst_make_benchmark.jl multisite2 RSSACR 1 5 9

echo "Starts benchmark runs on the egfr_net model."
time ${run_julia} --threads $JULIA_THREADS_TO_USE catalyst_make_benchmark.jl egfr_net RSSACR 1 3 7

echo "Starts benchmark runs on the BCR model."
#time julia --threads $JULIA_THREADS_TO_USE catalyst_make_benchmark.jl BCR RSSACR 3.398 5.01 3

echo "Starts benchmark runs on the fceri_gamma2 model."
#time julia --threads $JULIA_THREADS_TO_USE catalyst_make_benchmark.jl fceri_gamma2 RSSACR 1 3 7
