using Dates
using HTTP
using JSON3
using SparseArrays
using DataFrames
using Serialization
using ProgressMeter

# Constants
const BASE_URL = "https://wikimedia.org/"
const API_URL = joinpath(BASE_URL, "api/rest_v1/metrics/pageviews/top-per-country/")
const HEADERS = Dict("accept" => "application/json", "User-Agent" => "socioscope")
const COUNTRIES = ["FR", "US"]

# Types
struct PageViewResponse
    articles::Vector{Any}
end

# API Interaction
function construct_url(country_code::String, date::Date)
    "$(API_URL)$(country_code)/all-access/$(year(date))/$(lpad(month(date),2,'0'))/$(lpad(day(date),2,'0'))"
end

function fetch_page_views(country_code::String, date::Date)
    response = @async HTTP.get(construct_url(country_code, date), headers=HEADERS)
    data = JSON3.read(fetch(response).body)
    articles = data.items[1].articles
    PageViewResponse(Vector{Any}(articles))
end


# Data Loading
function data_fn()
    data_path = "data/wikitivity.jls"
    isdir("data") || mkdir("data")

    if isfile(data_path)
        return deserialize(data_path)
    end

    end_date = today() - Day(2)
    start_date = Date(2021, 1, 1)
    dates = start_date:Day(1):end_date

    results = Dict{String,Dict{Date,PageViewResponse}}()

    for country in COUNTRIES
        println("Fetching data for $country...")
        country_results = Dict{Date,PageViewResponse}()

        # Create tasks for all dates
        tasks = Dict(date => @async try
            fetch_page_views(country, date)
        catch e
            @warn "Failed to fetch data for $country on $date: $e"
            nothing
        end for date in dates)

        # Progress bar for fetch completion
        p = Progress(length(dates), desc="Fetching $country: ")

        # Collect results as they complete
        for date in dates
            result = fetch(tasks[date])
            if !isnothing(result)
                country_results[date] = result
            end
            next!(p)
            sleep(0.02)  # Small delay to be nice to the API
        end

        results[country] = country_results
    end

    serialize(data_path, results)
    results
end
