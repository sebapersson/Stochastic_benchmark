# Fetch packages.
using JumpProcesses
using SBMLImporter
using Catalyst
using ReactionNetworkImporters
using Test

struct ReactionInfo
    parameters::String
    reactants::Vector{String}
    products::Vector{String}
end
function ReactionInfo(reaction)
    reaction = replace(reaction, " " => "")
    lhs, rhs = split(reaction, "-->")
    products = Vector{String}(split(rhs, "+"))
    lhs, rhs = split(lhs, ",")
    reactants = Vector{String}(split(rhs, "+"))
    parameters = lhs
    return ReactionInfo(parameters, reactants, products)
end

function replace_digit(str)
    for (i, char) in pairs(str)
        if isdigit(char)
            if i > 1
                if isletter(str[i-1])
                    continue
                end
            end
            if !(length(str) ≥ 2 + i)
                continue
            end
            if str[i+1:i+2] != ".0"
                continue
            end
            if length(str) == i + 2
                return str[1:i]
            end
            str1 = str[1:i]
            str2 = str[i+3:end]
            return str1*str2
        end
    end
    return str
end

function isequal_reaction(r1::ReactionInfo, r2::ReactionInfo)::Bool
    if replace_digit(r1.parameters) != replace_digit(r2.parameters)
        return false
    end
    if length(r1.reactants) != length(r2.reactants)
        return false
    end
    if length(r1.products) != length(r2.products)
        return false
    end

    for prod in r1.products
        if prod ∉ r2.products
            return false
        end
    end
    for reac in r1.reactants
        if reac ∉ r2.reactants
            return false
        end
    end

    return true
end

function make_jprob(model, solver; tend = 10.0)
    dprob = DiscreteProblem(model.rn, model.u₀, (0.0,tend), model.p)
    dprob = remake(dprob, u0 = Int64.(dprob.u0), p = Float64.(dprob.p));
    return JumpProblem(model.rn, dprob, solver(), save_positions=(false,false))
end

# Load model.
model_name = "multisite3"
model_sbml, _ = load_SBML("../Models/$(model_name).xml", mass_action=true)
model_rni = loadrxnetwork(BNGNetwork(), "../Models/$(model_name).net")
parameters_sbml = string.(parameters(model_sbml.rn))
parameters_rni = string.(parameters(model_rni.rn))

# Test that initial values are
jprob_sbml = make_jprob(model_sbml, Direct)
jprob_rni = make_jprob(model_rni, Direct)
for i in eachindex(jprob_rni.prob.u0)
    isbml = findfirst(x -> x == "S" * string(i), replace.(string.(species(model_sbml.rn)), "(t)" => ""))
    @test jprob_rni.prob.u0[i] == jprob_sbml.prob.u0[isbml]
end

# Make rni species to those of sbml
species_rni = replace.(string.(species(model_rni.rn)), "(t)" => "")
species_sbml = ["S" * string(i) for i in 1:length(species_rni)]
species_mapping = [species_rni[i] => species_sbml[i] for i in eachindex(species_rni)]
reactions_rni = string.(reactions(model_rni.rn))
reactions_sbml = string.(reactions(model_sbml.rn))
for i in eachindex(reactions_rni)
    iuse = findall(occursin.(first.(species_mapping), reactions_rni[i]))
    if isempty(iuse)
        continue
    end
    reactions_rni[i] = replace(reactions_rni[i], species_mapping[iuse]...)
end

# Build ReactionInfo
rinfo_sbml = Vector{ReactionInfo}(undef, length(reactions_rni))
rinfo_rni = similar(rinfo_sbml)
for i in eachindex(rinfo_sbml)
    rinfo_sbml[i] = ReactionInfo(reactions_sbml[i])
    rinfo_rni[i] = ReactionInfo(reactions_rni[i])
end

ilist = zeros(Int64, length(rinfo_sbml))
for i in eachindex(ilist)
    @info "i = $i"
    for j in eachindex(ilist)
        if j in ilist
            continue
        end
        if isequal_reaction(rinfo_sbml[i], rinfo_rni[j])
            ilist[i] = j
            break
        end
    end
end

@test length(unique(ilist)) == length(ilist)
