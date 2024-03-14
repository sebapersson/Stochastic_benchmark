model_str = SBMLImporter._reactionsystem_from_SBML(_model_SBML; check_massaction=false)

SBMLImporter.reactionsystem_to_string(model_str, true, "Model.jl", _model_SBML)
