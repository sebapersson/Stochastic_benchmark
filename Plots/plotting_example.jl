### Set-up ###

# Activate local environment.
cd(@__DIR__)
import Pkg
Pkg.activate(".")

# Fetch packages.
using JSON
using Plots
using Statistics

# Sets default plotting options.
default(lw=4, la=0.6, markersize=6, markeralpha=0.8, framestyle=:box, gridalpha=0.2, gridlinewidth=1.0,
        legend=:bottomright)

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
function plot_bm(bm::MetodBenchmark; label = "", kwargs...)
    plot()
    plot_bm!(bm::MetodBenchmark; label = label, kwargs...)
end
function plot_bm!(bm::MetodBenchmark; label = "", kwargs...)
    plot!(bm.lengs, bm.vals; xaxis=:log10, yaxis=:log10, markers=true, label = label, kwargs...)
end

# Plots a full suite of benchmarks.
function plot_benchmarks(model)
    sbmlimporter_direct_bm = MetodBenchmark("Direct", "SBMLImporter", model)
    sbmlimporter_sortingdirect_bm = MetodBenchmark("SortingDirect", "SBMLImporter", model)
    sbmlimporter_RSSA_bm = MetodBenchmark("RSSA", "SBMLImporter", model)
    sbmlimporter_RSSACR_bm = MetodBenchmark("RSSACR", "SBMLImporter", model)
    roadrunner_SSA_bm = MetodBenchmark("SSA", "RoadRunner", model)
    pysb_nf_bm = MetodBenchmark("nf", "PySB", model)
    pysb_ssa_bm = MetodBenchmark("ssa", "PySB", model)

    plot()
    sbmlimporter_direct_bm.completed && plot_bm!(sbmlimporter_direct_bm; color=:skyblue, label = "SBMLImporter (Direct)")
    sbmlimporter_sortingdirect_bm.completed && plot_bm!(sbmlimporter_sortingdirect_bm; color=:lightblue, label = "SBMLImporter (Sorting direct)")
    sbmlimporter_RSSA_bm.completed && plot_bm!(sbmlimporter_RSSA_bm; color=:blue, label = "SBMLImporter (RSSA)")
    sbmlimporter_RSSACR_bm.completed && plot_bm!(sbmlimporter_RSSACR_bm; color=:navyblue, label = "SBMLImporter (RSSACR)")
    roadrunner_SSA_bm.completed && plot_bm!(roadrunner_SSA_bm; color=:green, label = "RoadRunner")
    pysb_nf_bm.completed && plot_bm!(pysb_nf_bm; color=:red, label = "PySB (NFsim)")
    pysb_ssa_bm.completed && plot_bm!(pysb_ssa_bm; color=:lightcoral, label = "PySB (NFsim)")
    plot!()
end

# Plots a full suite of benchmarks.
function julia_importer_comparisson(model)
    sbmlimporter_direct_bm = MetodBenchmark("Direct", "SBMLImporter", model)
    sbmlimporter_sortingdirect_bm = MetodBenchmark("SortingDirect", "SBMLImporter", model)
    sbmlimporter_RSSA_bm = MetodBenchmark("RSSA", "SBMLImporter", model)
    sbmlimporter_RSSACR_bm = MetodBenchmark("RSSACR", "SBMLImporter", model)
    
    reactionnetworkimporters_direct_bm = MetodBenchmark("Direct", "ReactionNetworkImporters", model)
    reactionnetworkimporters_sortingdirect_bm = MetodBenchmark("SortingDirect", "ReactionNetworkImporters", model)
    reactionnetworkimporters_RSSA_bm = MetodBenchmark("RSSA", "ReactionNetworkImporters", model)
    reactionnetworkimporters_RSSACR_bm = MetodBenchmark("RSSACR", "ReactionNetworkImporters", model)

    plot()
    sbmlimporter_direct_bm.completed && plot_bm!(sbmlimporter_direct_bm; color=:blue, label = "SBMLImporter (Direct)", lw=10, markersize=12)
    reactionnetworkimporters_direct_bm.completed && plot_bm!(reactionnetworkimporters_direct_bm; color=:orange, label = "ReactionNetworkImporters (Direct)", la=1.0, markeralpha = 1.0)
    p1 = plot!()

    plot()
    sbmlimporter_sortingdirect_bm.completed && plot_bm!(sbmlimporter_sortingdirect_bm; color=:blue, label = "SBMLImporter (SortingDirect)", lw=10, markersize=12)
    reactionnetworkimporters_sortingdirect_bm.completed && plot_bm!(reactionnetworkimporters_sortingdirect_bm; color=:orange, label = "ReactionNetworkImporters (SortingDirect)", la=1.0, markeralpha = 1.0)
    p2 = plot!()

    plot()
    sbmlimporter_RSSA_bm.completed && plot_bm!(sbmlimporter_RSSA_bm; color=:blue, label = "SBMLImporter (RSSA)", lw=10, markersize=12)
    reactionnetworkimporters_RSSA_bm.completed && plot_bm!(reactionnetworkimporters_RSSA_bm; color=:orange, label = "ReactionNetworkImporters (RSSA)", la=1.0, markeralpha = 1.0)
    p3 = plot!()

    plot()
    sbmlimporter_RSSACR_bm.completed && plot_bm!(sbmlimporter_RSSACR_bm; color=:blue, label = "SBMLImporter (RSSACR)", lw=10, markersize=12)
    reactionnetworkimporters_RSSACR_bm.completed && plot_bm!(reactionnetworkimporters_RSSACR_bm; color=:orange, label = "ReactionNetworkImporters (RSSACR)", la=1.0, markeralpha = 1.0)
    p4 = plot!()

    plot(p1, p2, p3, p4, layout=(2,2), size=(1200,700))
end

### Plot Benchmarks.

# Benchmarks.
plot_benchmarks("multistate")
plot_benchmarks("multisite2")
plot_benchmarks("egfr_net")
plot_benchmarks("BCR")
plot_benchmarks("fceri_gamma2")

# Compares SBMLImporter and ReactionNetworkImporters.
julia_importer_comparisson("multistate")
julia_importer_comparisson("multisite2")
julia_importer_comparisson("egfr_net")
julia_importer_comparisson("BCR")
julia_importer_comparisson("fceri_gamma2")
