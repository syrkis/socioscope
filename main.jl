# %% Includes
include("types.jl")

# %% Usings
using DataFrames
using Dates
using HTTP
using JSON3
using Memoize
using ProgressMeter
using Revise
using Serialization
using SparseArrays

# %% Constants
DATE_RANGE = Date(2021, 1, 1):Day(1):today()-Day(2)
COUNTRIES = ["FR", "US"]


# %%
function url_fn(country_code::String, date::Date)
    api_url = joinpath("https://wikimedia.org/", "api/rest_v1/metrics/pageviews/top-per-country/")
    "$(api_url)$(country_code)/all-access/$(year(date))/$(lpad(month(date),2,'0'))/$(lpad(day(date),2,'0'))"
end

@memoize function fetch_fn(country_code::String, date::Date)  # memoize to not call api too much
    headers = Dict("accept" => "application/json", "User-Agent" => "socioscope")
    response = @async HTTP.get(url_fn(country_code, date), headers=headers)
    articles = JSON3.read(fetch(response).body).items[1].articles
    DailyStats([PageView(a.article, a.views_ceil, a.project) for a in articles], date)
end

function country_fn(country::String, date_range::StepRange{Date})
    CountryStats(Dict(@showprogress "Fetching $country: " asyncmap(date -> date => fetch_fn(country, date), date_range)))
end

function data_fn()
    map(country -> country => country_fn(country, DATE_RANGE), COUNTRIES)
end

country_fn("US", DATE_RANGE)

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
