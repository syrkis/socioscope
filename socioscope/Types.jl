using Dates

# %% Types
struct PageView
    name::String
    view::Int
    wiki::String
end

struct DailyStats
    page::Vector{PageView}
    date::Date
end

# struct CountryStats
    # stats::Dict{Date,DailyStats}
# end
