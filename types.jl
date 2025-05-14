# %% Imports
using Dates

# %% Types
struct PageView
    article::String
    views::Int
    project::String
end

struct DailyStats
    articles::Vector{PageView}
    date::Date
end

struct CountryStats
    stats::Dict{Date,DailyStats}
end

struct WikiConfig
    base_url::String
    api_url::String
    headers::Dict{String,String}
    countries::Vector{String}
    data_path::String
end
