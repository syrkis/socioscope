# %% Includes
include("utils.jl")
include("types.jl")

# %% Usings
using SparseArrays
using DataFrames
using SparseArrays


# %% Functions
function plc2mat(data, country, a2i)
    map(y -> day2vec(y, a2i), values(data[country].stats))
    [v for v in values(data[country].stats)] |> x -> map(y -> day2vec(y, a2i), x) |> stack |> transpose
end

function day2vec(x, a2i)
    I = map(y -> a2i[y.article], x.articles)
    V = map(y -> y.views, x.articles)
    return sparsevec(I, V, length(a2i))
end

function day2set(x)
    map(y -> y.article, x.articles) |> Set
end

function plc2set(x)
    map(day2set, values(x.stats)) |> x -> reduce(union, x)
end

function dat2voc(data)
    vocab = reduce(union, map(plc2set, values(data)))
    a2i = Dict(a => i for (i, a) in enumerate(vocab))
    i2a = Dict(i => a for (i, a) in pairs(a2i))
    vocab, a2i, i2a
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

# %% Main
data = load_or_fetch_data()
data["FR"]
