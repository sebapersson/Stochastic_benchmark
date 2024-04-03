# We strongly recomend Julia 1.10
pathJulia="julia"

# To use Conda (Fides in Julia)
eval "$(conda shell.bash hook)"

echo "Installing Python packages for PySB"
cd PySB
conda env create -f Stochastic_benchmark.yml
cd ..
echo "Done"

echo "Installing Julia packages for SBMLImporter"
cd SBMLImporter
${pathJulia} --project=. -e"using Pkg; Pkg.instantiate()"
cd ..
echo "Done"

echo "Installing Julia packages for ReactionNetworkImporters"
cd ReactionNetworkImporters
${pathJulia} --project=. -e"using Pkg; Pkg.instantiate()"
cd ..
echo "Done"

echo "Installing Julia packages for RoadRunner"
cd RoadRunner
${pathJulia} --project=. -e"using Pkg; Pkg.instantiate()"
cd ..
echo "Done"