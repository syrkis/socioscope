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
COUNTRIES = ["FR", "US", "DK"]

# %% Make url for requesting activity of country at date
function url_fn(country_code::String, date::Date)
    api_url = joinpath("https://wikimedia.org/", "api/rest_v1/metrics/pageviews/top-per-country/")
    "$(api_url)$(country_code)/all-access/$(year(date))/$(lpad(month(date),2,'0'))/$(lpad(day(date),2,'0'))"
end

# %% Fetch url and return page view list
@memoize function fetch_fn(country_code::String, date::Date)  # memoize to not call api too much
    headers = Dict("accept" => "application/json", "User-Agent" => "socioscope")
    response = @async HTTP.get(url_fn(country_code, date), headers=headers)
    articles = JSON3.read(fetch(response).body).items[1].articles
    [PageView(a.article, a.views_ceil, a.project) for a in articles]
end

# Return data for all countries (outter map) for all dates (inner asyncmap)
function data_fn()
    Dict(map(country -> country => Dict(@showprogress "Fetching $country: " asyncmap(date -> date => fetch_fn(country, date), DATE_RANGE)), COUNTRIES))
end
