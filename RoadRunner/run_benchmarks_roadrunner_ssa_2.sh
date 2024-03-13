#!/bin/bash

JULIA_THREADS_TO_USE=1

echo "Starts benchmark runs on the BCR model."
time julia --threads $JULIA_THREADS_TO_USE roadrunner_make_benchmark.jl BCR SSA 3.398 4.204 2
