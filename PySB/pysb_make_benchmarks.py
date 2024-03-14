### Preparations ###

# Fetch packages.
import sys
import json
import statistics
import timeit
import pysb
import numpy
from pysb.importers.bngl import model_from_bngl
from pysb.examples import robertson
from pysb.simulator.bng import BngSimulator

# Check thread count.
import threading
print(f'Threads in use: {threading.active_count()}')

# Read input.
modelname = sys.argv[1]
method = sys.argv[2]
minT = float(sys.argv[3])
maxT = float(sys.argv[4])
nT = int(sys.argv[5])
num_sims = int(sys.argv[6])

if method not in ['nf', 'ssa']:
    raise Exception("Provided an invalid method.")

# Benchmarking parameters
n = num_sims
lengs = numpy.logspace(minT, maxT, num=nT)

# Benchmarking functions.
def make_ssa_benchmark(simulator, n):    
    def benchmark_func():
        simulator.run(n_runs=1, method=method, gml=1000000)
    durations = timeit.Timer(benchmark_func).repeat(repeat=n, number=1)
    return durations

# Serialises a benchmarking output using JSON.
def serialize(benchmarks, lengs, filename):
    with open(f'../Results/PySB/%s.json'%(filename) , "w") as write:
        json.dump({"benchmarks": benchmarks, "medians": list(1000*numpy.array(list(map(statistics.median, benchmarks)))), "lengs": lengs.tolist()} , write)


### Benchamrks ###

# Load model.
model = model_from_bngl(f'../Models/{modelname}.bngl')

# Benchmark ODE simulations.
benchmarks = [-1.0] * len(lengs)
for i in range(0,len(lengs)):
    simulator = BngSimulator(model, tspan=numpy.linspace(0, lengs[i], 2)) 
    benchmarks[i] = make_ssa_benchmark(simulator, n)

# Save benchmarks.
serialize(benchmarks, lengs, f'{method}_{modelname}')

