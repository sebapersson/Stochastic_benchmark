#!/bin/bash

JULIA_THREADS_TO_USE=1

echo "Starts benchmark runs on the fceri_gamma2 model."
time julia --threads $JULIA_THREADS_TO_USE roadrunner_make_benchmark.jl fceri_gamma2 SSA 1 2 4
