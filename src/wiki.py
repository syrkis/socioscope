# wiki.py
#   sociscope wiki data file
# by: Noah Syrkis

# imports
import requests as req
import pandas as pd
import sqlite3
from datetime import datetime, timedelta
import wikipediaapi
from tqdm import tqdm
import yaml
import os

# globals
base      = 'https://wikimedia.org/api/rest_v1/metrics/pageviews/top-per-country'
api       = lambda c, d: f"{base}/{c}/all-access/{d.year}/{str(d.month).zfill(2)}/{str(d.day).zfill(2)}"
headers   = { 'User-Agent': 'nobr@itu.dk', 'accept' : 'application/json' }
cols      = 'article project views_ceil rank'.split()
database  = '/Users/syrkis/data/socioscope/wiki.db'

#  functions
def get_wiki(dates, countries):
    con = sqlite3.connect(database)
    cur = con.cursor()

    # ensure countries are in db
    old_countries = set([c[0] for c in cur.execute("SELECT country_code FROM Country")])
    new_countries = [(c,) for c in countries if c not in old_countries]
    cur.executemany("INSERT INTO Country (country_code) VALUES (?)", new_countries)
    con.commit()

    # Retrieve country_id for all countries
    country_ids = {code: id for id, code in cur.execute("SELECT country_id, country_code FROM Country")}
    for country_code, country_id, in country_ids.items():
        for date_time in tqdm(dates):
            date = date_time.date()
            # Check if the date and country_id combination is already in the database
            query = "SELECT * FROM Views WHERE view_date = ? AND country_id = ?"
            if cur.execute(query, (date, country_id)).fetchone() is None:
                res = req.get(api(country_code, date), headers=headers).json()['items'][0]['articles']
                df = pd.DataFrame(res)
                get_day(date, country_id, df, cur, con)  # Pass country_id instead of country_code
    con.close()

            
def get_day(date, country_id, df, cur, con):
    # Add new projects and fetch their IDs
    old_projects = {p[0]: p[1] for p in cur.execute("SELECT project_name, project_id FROM Project")}
    new_projects = [(p,) for p in df['project'].unique() if p not in old_projects]
    if new_projects: cur.executemany("INSERT INTO Project (project_name) VALUES (?)", new_projects)
    project_ids = {p[0]: p[1] for p in cur.execute("SELECT project_name, project_id FROM Project")}
    ids_project = {v: k for k, v in project_ids.items()}
    con.commit()

    old_articles = [(p[0], p[1]) for p in cur.execute("SELECT article_name, project_id FROM Article")]
    new_articles = [(row['article'], project_ids[row['project']]) for i, row in df.iterrows()
                    if (row['article'], project_ids[row['project']]) not in old_articles]
    if new_articles: cur.executemany("INSERT INTO Article (article_name, project_id) VALUES (?, ?)", new_articles)
    article_ids = {(p[0], ids_project[p[1]]): p[2] for p in cur.execute("SELECT article_name, project_id, article_id FROM Article")}
    con.commit()

    articles = [article_ids[(row['article'], row['project'])] for i, row in df.iterrows()]
    views    = df['views_ceil']
    data = [(country_id, article_id, date, view_count) for article_id, view_count in zip(articles, views)]
    if data: cur.executemany("INSERT INTO Views (country_id, article_id, view_date, view_count) VALUES (?, ?, ?, ?)", data)
    con.commit()


# main
def main():
    countries = 'US JP DK BR PT FR'.split()
    date_two_days_ago = (datetime.now() - timedelta(days=2)).strftime('%Y/%m/%d')
    dates     = pd.date_range('2024/01/01', date_two_days_ago)
    get_wiki(dates, countries)

if __name__ == "__main__":
    main()
