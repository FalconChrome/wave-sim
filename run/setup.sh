apt update && apt install -y curl && curl -fsSL https://install.julialang.org | sh -s -- -y

julia
using Pkg; Pkg.activate("WaveSim/"); Pkg.instantiate()
