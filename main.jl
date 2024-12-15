# main.jl
include("src/data.jl")
using SparseArrays

# Function to load or fetch data (only runs once)
function load_data()
    data = data_fn()
    data
end

# Function to create vocabulary (can be rerun quickly)
function create_vocab(data, country)
    map(x -> map(y -> y.article, x.articles) |>
             Set, values(data[country])) |>
    x -> reduce(union, x) |>
         collect |>
         sort
end

# Analysis functions can go here...
function create_dictionary(vocab)
    a2i = Dict(a => i for (i, a) in enumerate(vocab))
    i2a = Dict(i => a for (i, a) in enumerate(vocab))
    a2i, i2a
end


function encode_day(data, country, date, a2i)
    data[country][date].articles |> x -> map(y -> y.article, x) |> x -> map(y -> get(a2i, y, 0), x)
end

function encode_country(data, country, a2i)
    keys(data[country]) |>
    collect |>
    x -> map(y -> encode_day(data, country, y, a2i), x)
end
