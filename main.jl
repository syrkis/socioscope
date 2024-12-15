# main.jl
include("src/data.jl")

function main()
    println("Fetching Wikipedia pageview data...")
    data = data_fn()
    println("Data fetching complete!")
    # Unique articles in the US dataset
    # map(x -> map(y -> y.article, x.articles) |> Set, values(data["US"])) |> x -> reduce(union, x)
    return data
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
