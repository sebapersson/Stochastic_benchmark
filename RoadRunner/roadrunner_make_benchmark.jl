### Set-up ###

# Activate local environment.
cd(@__DIR__)
import Pkg
Pkg.activate(".")
println("Threads in use: $(Threads.nthreads())")

# Fetch packages.
using BenchmarkTools
using JSON
using RoadRunner
using TimerOutputs


### Read Inputs ###

# (If ARGS empty, we are probably running in e.g. VSCode to test stuff, then give some simple case).
modelName, methodName, minT, maxT, nT = (isempty(ARGS) ? ["multistate", "SSA", "1", "4", "7"] : ARGS[1:5])

# Computes the benchmarking simulation lengths.
lengs = 10 .^(range(parse(Float64,minT),stop=parse(Float64,maxT),length=parse(Int64,nT)));

# Load model.
begin
    filename = "../Models/$(modelName)_no_obs.xml"
    opened_file = open(filename)
    sbml_str = read(filename,String)
    close(opened_file)
    model = RoadRunner.createRRInstance()
    RoadRunner.loadSBML(model, sbml_str)
end


### Helper Functions ###

# Declares a serilization function.
function serialize_benchmarks(benchmarks, lengs, methodName)
    medians = map(bm -> median(bm.times)/1000000, benchmarks)
    open("../Results/RoadRunner/$(methodName)_$(modelName).json","w") do f
        JSON.print(f, Dict("benchmarks"=>benchmarks, "medians"=>medians, "lengs"=>lengs))
    end
end

# Benchmark_models model
function benchmark_model(model, l, methodName)
    RoadRunner.setTimeCourseSelectionList(model, "")

    if methodName == "SSA"
        return @benchmark ssa_simulate_model($model, $l)
    else
        error("Invalid method name given: $(methodName)")
    end
end
function ssa_simulate_model(model, l)
    RoadRunner.resetRR(model)
    RoadRunner.gillespieEx(model, 0., l)
end

### Benchmarking ###

# Proclaims benchmark begins.
println("\n-----     Beginning benchmarks for $(modelName) using $(methodName).     -----")

# Make benchmarks.
benchmarks = map(leng -> benchmark_model(model, leng, methodName), lengs)
serialize_benchmarks(benchmarks, lengs, methodName)

# Proclaims benchmark over.
println("-----     Benchmark finished.     -----")
