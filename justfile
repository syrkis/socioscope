# justfile

default:
    just run

run:
    julia --project=. main.jl

repl:
    julia --project=. -i repl.jl

setup:
    julia --project=. -e 'using Pkg; Pkg.activate("."); Pkg.instantiate()'
