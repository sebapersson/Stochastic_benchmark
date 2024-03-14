### Set-up ###

# Activate local environment.
cd(@__DIR__)
import Pkg
Pkg.activate(".")

# Fetch packages.
using JSON
using Plots
using Statistics

# Gathers the information of a single benchmark in a single structure.
struct MetodBenchmark
    lengs::Vector{Float64}
    vals::Vector{Float64}
    completed::Bool

    function MetodBenchmark(method::String, tool::String, model::String; print_missing = true)
        filename = "../Results/$tool/$(method)_$(model).json"
        if !isfile(filename) 
            print_missing && println("Missing benchmark: $(method)")
            return new(Float64[],Float64[],false)
        end
        bm = JSON.parsefile(filename)
        return new(Float64.(bm["lengs"]), bm["medians"], true)
    end
end

# Plots a benchmark.
function plot_bm(bm::MetodBenchmark; kwargs...)
    plot()
    plot_bm!(bm::MetodBenchmark; kwargs...)
end
function plot_bm!(bm::MetodBenchmark; kwargs...)
    plot!(bm.lengs, bm.vals; label="", xaxis=:log10, yaxis=:log10, kwargs...)
    plot!(bm.lengs, bm.vals; xaxis=:log10, yaxis=:log10, seriestype=:scatter, kwargs...)
end

### Plot Benchmarks.

# Multistate
sbmlimporter_multistate_direct_bm = MetodBenchmark("Direct", "SBMLImporter", "multistate")
sbmlimporter_multistate_sortingdirect_bm = MetodBenchmark("SortingDirect", "SBMLImporter", "multistate")
sbmlimporter_multistate_RSSA_bm = MetodBenchmark("RSSA", "SBMLImporter", "multistate")
sbmlimporter_multistate_RSSACR_bm = MetodBenchmark("RSSACR", "SBMLImporter", "multistate")
roadrunner_multistate_SSA_bm = MetodBenchmark("SSA", "RoadRunner", "multistate")
pysb_multistate_nf_bm = MetodBenchmark("nf", "PySB", "multistate")

plot_bm(sbmlimporter_multistate_direct_bm; color=:skyblue)
plot_bm!(sbmlimporter_multistate_sortingdirect_bm; color=:lightblue)
plot_bm!(sbmlimporter_multistate_RSSA_bm; color=:blue)
plot_bm!(sbmlimporter_multistate_RSSACR_bm; color=:navyblue)
plot_bm!(roadrunner_multistate_RSSACR_bm; color=:red)
plot_bm!(pysb_multistate_nf_bm; color=:green)