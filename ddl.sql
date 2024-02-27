CREATE TABLE Project (
    project_id INTEGER PRIMARY KEY,
    project_name TEXT NOT NULL,
    description TEXT,
    start_date DATE,
    end_date DATE
);

CREATE TABLE Country (
    country_id INTEGER PRIMARY KEY,
    country_name TEXT NOT NULL,
    population INTEGER,
    region TEXT
);

CREATE TABLE Concept (
    concept_id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT
);

CREATE TABLE Article (
    article_id INTEGER PRIMARY KEY,
    concept_id INTEGER,
    project_id INTEGER,
    language TEXT NOT NULL,
    last_updated DATE,
    edit_count INTEGER,
    FOREIGN KEY (concept_id) REFERENCES Concept(concept_id),
    FOREIGN KEY (project_id) REFERENCES Project(project_id)
);

CREATE TABLE Links (
    from_article_id INTEGER,
    to_article_id INTEGER,
    link_type TEXT, -- e.g., 'internal', 'external'
    link_date DATE,
    FOREIGN KEY (from_article_id) REFERENCES Article(article_id),
    FOREIGN KEY (to_article_id) REFERENCES Article(article_id)
);

CREATE TABLE Views (
    country_id INTEGER,
    article_id INTEGER,
    view_count INTEGER,
    view_data DATE,
)

-- Indexes to improve query performance
CREATE INDEX idx_project_name ON Project(project_name);
CREATE INDEX idx_country_name ON Country(country_name);
CREATE INDEX idx_concept_title ON Concept(title);
CREATE INDEX idx_article_concept ON Article(concept_id);
CREATE INDEX idx_article_country ON Article(country_id);
CREATE INDEX idx_links_from_to ON Links(from_article_id, to_article_id);
