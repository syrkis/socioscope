# repl.jl
include("src/data.jl")
println("Loading data...")
data = data_fn()
println("Data loaded! Variable \"data\" is now in scope.")
