include("types.jl")

# %% Usings
using HTTP
using JSON3
using ProgressMeter
using Serialization

# Configuration
function create_default_config()
    base_url = "https://wikimedia.org/"
    api_url = joinpath(base_url, "api/rest_v1/metrics/pageviews/top-per-country/")
    headers = Dict("accept" => "application/json", "User-Agent" => "socioscope")
    countries = ["FR", "US"]
    data_path = "data/wikitivity.jls"

    WikiConfig(base_url, api_url, headers, countries, data_path)
end

# API Interaction
function construct_url(config::WikiConfig, country_code::String, date::Date)
    "$(config.api_url)$(country_code)/all-access/$(year(date))/$(lpad(month(date),2,'0'))/$(lpad(day(date),2,'0'))"
end

function fetch_page_views(config::WikiConfig, country_code::String, date::Date)
    response = @async HTTP.get(
        construct_url(config, country_code, date),
        headers=config.headers
    )
    articles = JSON3.read(fetch(response).body).items[1].articles
    DailyStats([PageView(a.article, a.views_ceil, a.project) for a in articles], date)
end

# Data Collection
function fetch_country_stats(config::WikiConfig, country::String, date_range::StepRange{Date})
    country_results = Dict{Date,DailyStats}()

    # Create tasks for all dates
    tasks = Dict(date => @async try
        fetch_page_views(config, country, date)
    catch e
        @warn "Failed to fetch data for $country on $date: $e"
        nothing
    end for date in date_range)

    # Progress bar for fetch completion
    p = Progress(length(date_range), desc="Fetching $country: ")

    # Collect results as they complete
    for date in date_range
        result = fetch(tasks[date])
        if !isnothing(result)
            country_results[date] = result
        end
        next!(p)
        sleep(0.02)  # Small delay to be nice to the API
    end

    CountryStats(country_results)
end

# Data Loading
function load_or_fetch_data(config::WikiConfig=create_default_config())
    isdir(dirname(config.data_path)) || mkdir(dirname(config.data_path))

    if isfile(config.data_path)
        return deserialize(config.data_path)
    end

    end_date = today() - Day(2)
    start_date = Date(2021, 1, 1)
    date_range = start_date:Day(1):end_date

    results = Dict{String,CountryStats}()

    for country in config.countries
        println("Fetching data for $country...")
        results[country] = fetch_country_stats(config, country, date_range)
    end

    serialize(config.data_path, results)
    results
end
