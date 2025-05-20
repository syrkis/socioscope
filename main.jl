# %% Imports
import Pkg; Pkg.activate(".");
include("socioscope/Types.jl"); include("socioscope/Utils.jl");
using DataFrames, Plots, HTTP, JSON3, ProgressMeter, Revise, Serialization, SparseArrays, Graphs, CSV;

# %%
data = data_fn();


# %%
vocab = Set(reduce(vcat, [reduce(vcat, [[(a.wiki, a.name) for a in day] for day in values(country)]) for country in values(data)]))
a2i = Dict(i => a for (a, i) in enumerate(vocab))
i2a = Dict(i => a for (i, a) in enumerate(vocab));

# function encode_fn()
# end
# tokid =
# %% TODO: for now, make vector based on ollama embedding of project plus title.

# https://en.wikipedia.org/w/api.php?action=query&prop=extracts&exintro=&explaintext=&titles=2000_Mexican_general_election&format=json
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
