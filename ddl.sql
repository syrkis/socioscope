PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS Country;
DROP TABLE IF EXISTS Concept;
DROP TABLE IF EXISTS Article;
DROP TABLE IF EXISTS Links;
DROP TABLE IF EXISTS Views;
DROP TABLE IF EXISTS Project;


CREATE TABLE IF NOT EXISTS Project (
    project_id INTEGER PRIMARY KEY AUTOINCREMENT,
    project_name TEXT UNIQUE
);

CREATE TABLE IF NOT EXISTS Country (
    country_id INTEGER PRIMARY KEY AUTOINCREMENT,
    country_code TEXT UNIQUE
);

CREATE TABLE IF NOT EXISTS Article (
    article_id INTEGER PRIMARY KEY AUTOINCREMENT,
    project_id INTEGER NOT NULL,
    article_name TEXT NOT NULL,
    FOREIGN KEY (project_id) REFERENCES Project(project_id),
    UNIQUE (article_name, project_id)
);

CREATE TABLE IF NOT EXISTS Views (
    country_id INTEGER,
    article_id INTEGER,
    view_count INTEGER,
    view_date DATE,
    PRIMARY KEY (country_id, article_id, view_date),
    FOREIGN KEY (country_id) REFERENCES Country(country_id),
    FOREIGN KEY (article_id) REFERENCES Article(article_id)
);

/*  for content api
CREATE TABLE IF NOT EXISTS Concept (
    concept_id INTEGER PRIMARY KEY,
    title TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS Summary (
    article_id INTEGER PRIMARY KEY,
    summary TEXT NOT NULL,
    last_updated DATE,
    edit_count INTEGER,
    FOREIGN KEY (concept_id) REFERENCES Concept(concept_id),
    FOREIGN KEY (project_id) REFERENCES Project(project_id)
);

CREATE TABLE IF NOT EXISTS Links (
    from_article_id INTEGER,
    to_article_id INTEGER,
    link_type TEXT, -- e.g., 'internal', 'external'
    link_date DATE,
    FOREIGN KEY (from_article_id) REFERENCES Article(article_id),
    FOREIGN KEY (to_article_id) REFERENCES Article(article_id)
);

-- Indexes to improve query performance
 */