#!/bin/bash

JULIA_THREADS_TO_USE=1
run_julia="julia"

for i in {1..7}
do
    if [[ "$i" == '2' ]]; then
        continue
    fi
    echo "Starts benchmark runs on the multisite model nr ${i}"
    model_run="multisite${i}"
    time ${run_julia} --threads $JULIA_THREADS_TO_USE reactionnetworkimporters_make_benchmark.jl ${model_run} RSSACR 1 3 3
done