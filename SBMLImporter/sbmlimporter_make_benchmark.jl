### Set-up ###

# Activate local environment.
cd(@__DIR__)
import Pkg
Pkg.activate(".")
println("Threads in use: $(Threads.nthreads())")

# Fetch packages.
using BenchmarkTools
using JSON
using JumpProcesses
using SBMLImporter
using TimerOutputs


### Read Inputs ###

# (If ARGS empty, we are probably running in e.g. VSCode to test stuff, then give some simple case).
modelName, methodName, minT, maxT, nT = (isempty(ARGS) ? ["multisite2", "RSSACR", "1", "4", "7"] : ARGS[1:5])

# Computes the benchmarking simulation lengths.
lengs = 10 .^(range(parse(Float64,minT),stop=parse(Float64,maxT),length=parse(Int64,nT)));

# Declares a serilization function.
function serialize_benchmarks(benchmarks, lengs, methodName)
    medians = map(bm -> median(bm.times)/1000000, benchmarks)
    open("../Results/SBMLImporter/$(methodName)_$(modelName).json", "w") do f
        JSON.print(f, Dict("benchmarks"=>benchmarks, "medians"=>medians, "lengs"=>lengs))
    end
end

# Sets the method.
solver = Dict(["Direct" => Direct, "SortingDirect" => SortingDirect, "RSSA" => RSSA, "RSSACR" => RSSACR])[methodName]

# Load model.
model, cb = load_SBML("../Models/$(modelName).xml"; mass_action = true)

### Benchmarking ###


# Declares beginning of benchmark.
println("\n-----     Beginning benchmarks for $(modelName) using $(methodName)     -----")

# Run becnhmarks.
dprob = DiscreteProblem(model.rn, model.u₀, (0.0,0.0), model.p)
dprob = remake(dprob, u0 = Int64.(dprob.u0));
jprob = JumpProblem(model.rn, dprob, solver(), save_positions=(false,false))
benchmarks = map(leng -> (jp_internal = remake(jprob,tspan=(0.0, leng)); (@benchmark solve($jp_internal, $(SSAStepper())));), lengs)
serialize_benchmarks(benchmarks, lengs, methodName)

# Proclaims benchmark over.
println("-----     Benchmark finished.     -----")
