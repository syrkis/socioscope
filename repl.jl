# repl.jl
include("src/data.jl")
println("Loading data...")
data, vocab = data_fn()
println("Data loaded! Variable \"data\" is now in scope.")
