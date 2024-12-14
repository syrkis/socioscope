# %% main.py
#     socioscope main
# by: Noah Syrkis

# Imports
import asyncio
import aiohttp
import pandas as pd
import datetime
import os
from tqdm.asyncio import tqdm
from urllib.parse import urljoin

# %% Constants
BASE_URL = "https://wikimedia.org/"
API_URL = urljoin(BASE_URL, "api/rest_v1/metrics/pageviews/top-per-country/")
HEADERS = {"accept": "application/json", "User-Agent": "socioscope"}
COUNTRIES = ["FR", "US"]  # Added countries list


# %% Functions
async def fetch_page_views(session, country_code, date):
    year, month, day = date.year, date.month, date.day
    url = urljoin(API_URL, f"{country_code}/all-access/{year}/{month:02d}/{day:02d}")
    async with session.get(url, headers=HEADERS) as response:
        json_data = await response.json()  # await the json() coroutine first
        return json_data["items"][0]["articles"]  # then access the data


async def fetch_all_page_views(countries, dates):
    async with aiohttp.ClientSession() as session:
        results = {}
        for country in tqdm(countries, desc="Countries"):
            tasks = {
                date: asyncio.create_task(fetch_page_views(session, country, date))
                for date in dates
            }
            country_results = await asyncio.gather(*tasks.values())
            results[country] = dict(zip(tasks.keys(), country_results))
        return results


# %% State
def load_wikitivity():
    os.makedirs("data", exist_ok=True)  # Ensure data directory exists
    if os.path.exists("data/wikitivity.pkl"):
        return pd.read_pickle("data/wikitivity.pkl")
    end_date = datetime.date.today() - datetime.timedelta(days=2)
    dates = pd.date_range(start="2021-01-01", end=end_date)
    wikitivity = asyncio.run(fetch_all_page_views(COUNTRIES, dates))
    pd.to_pickle(wikitivity, "data/wikitivity.pkl")
    return wikitivity


# %% Main
wikitivity = load_wikitivity()

# %%
[e["article"] for e in wikitivity["US"][pd.Timestamp("2024-01-01")]]
