# main.jl
include("src/data.jl")

function main()
    println("Fetching Wikipedia pageview data...")
    data = data_fn()
    println("Data fetching complete!")
    return data
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
