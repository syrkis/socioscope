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
