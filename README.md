# Benchmark Stochastic Simulators

This repository contains scripts for running the benchmark comparing stochastic simulators for PySB, RoadRunner, SBMLImporter.jl and ReactionNetworkImporters.jl.

**Note**: The benchmark takes a substantial amount of time to run. Therefore, we provide the results files in *Results* folder.

## Setup

To set up the benchmark, follow these steps:

1. Make sure you have a Julia 1.10 executable (or a later version) located at *path\_to\_julia*.
2. Have a valid conda installation.
3. Run the command ```bash setup.sh``` from the project's root directory to install all the required packages.

**Note**: You will need to manually set the Julia executable path in the *setup.sh* file.

**Note**: The compilation time for Julia can be significant ([xkcd reference](https://xkcd.com/303/)).

To process the results, you will need R (version $\geq$ 4.0).

## Running the Benchmark

To execute the benchmark, navigate to the specific software directory and initiate one of the provided bash scripts. For instance, to run the benchmark with SBMLImporter using the `RSSACR` simulator, enter the following commands in a bash terminal:

```bash
cd SBMLImporter
bash run_benchmarks_sbmlimporter_ssa_RSSACR_1.sh
```

This process will execute the benchmark for several models; multistate, mulisite3, egfr_net, and fceri_gamma2. Note that the BCR model requires a separate script. The benchmarks are divided across multiple bash scripts to facilitate workload parallelization.

## Processing Results

The results can be processed using the *Plot.R* script (make sure to run it from the script's location to set the path correctly) in the *Plots* folder. This script will generate individual all the plots found in the paper.
