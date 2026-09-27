-- TritonLab initial schema. Matches docs/data_dictionary.md.
CREATE EXTENSION IF NOT EXISTS vector;
CREATE SCHEMA IF NOT EXISTS raw;

CREATE TABLE IF NOT EXISTS institution (
    institution_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    type TEXT NOT NULL CHECK (type IN ('ucsd', 'institute'))
);

CREATE TABLE IF NOT EXISTS department (
    department_id SERIAL PRIMARY KEY,
    institution_id INT NOT NULL REFERENCES institution(institution_id),
    name TEXT NOT NULL,
    website TEXT,
    UNIQUE (institution_id, name)
);

CREATE TABLE IF NOT EXISTS researcher (
    researcher_id SERIAL PRIMARY KEY,
    full_name TEXT NOT NULL,
    title TEXT,
    email TEXT,
    department_id INT REFERENCES department(department_id),
    openalex_id TEXT UNIQUE,
    nih_pi_id TEXT,
    orcid TEXT
);

CREATE TABLE IF NOT EXISTS lab (
    lab_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    pi_researcher_id INT NOT NULL REFERENCES researcher(researcher_id),
    website TEXT,
    description TEXT
);

CREATE TABLE IF NOT EXISTS paper (
    paper_id SERIAL PRIMARY KEY,
    openalex_id TEXT UNIQUE,
    title TEXT NOT NULL,
    abstract TEXT,
    publication_date DATE,
    venue TEXT,
    topics TEXT[]
);

CREATE TABLE IF NOT EXISTS authorship (
    paper_id INT NOT NULL REFERENCES paper(paper_id),
    researcher_id INT NOT NULL REFERENCES researcher(researcher_id),
    author_position INT,
    PRIMARY KEY (paper_id, researcher_id)
);

CREATE TABLE IF NOT EXISTS grant_award (
    grant_id SERIAL PRIMARY KEY,
    source TEXT NOT NULL CHECK (source IN ('nih', 'nsf')),
    award_number TEXT NOT NULL,
    pi_researcher_id INT REFERENCES researcher(researcher_id),
    title TEXT,
    abstract TEXT,
    amount_usd NUMERIC,
    start_date DATE,
    end_date DATE,
    UNIQUE (source, award_number)
);

CREATE TABLE IF NOT EXISTS lab_features (
    lab_id INT PRIMARY KEY REFERENCES lab(lab_id),
    undergrad_prob REAL,
    undergrad_label TEXT CHECK (undergrad_label IN ('likely', 'possible', 'unclear')),
    activity_score REAL,
    activity_breakdown JSONB,
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- Dimension is left open until the embedding model is chosen in Week 2.
-- Add an HNSW index in Week 3 after fixing the dimension.
CREATE TABLE IF NOT EXISTS embedding (
    entity_type TEXT NOT NULL CHECK (entity_type IN ('lab', 'paper', 'student')),
    entity_id INT NOT NULL,
    model TEXT NOT NULL,
    embedding VECTOR NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now(),
    PRIMARY KEY (entity_type, entity_id, model)
);

CREATE TABLE IF NOT EXISTS student_profile (
    student_id SERIAL PRIMARY KEY,
    interests TEXT,
    resume_text TEXT,
    courses TEXT[],
    skills TEXT[],
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS interaction (
    interaction_id SERIAL PRIMARY KEY,
    student_id INT NOT NULL REFERENCES student_profile(student_id),
    lab_id INT NOT NULL REFERENCES lab(lab_id),
    type TEXT NOT NULL CHECK (type IN
        ('view', 'save', 'good_fit', 'not_for_me', 'outreach_sent', 'reply')),
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_interaction_student ON interaction(student_id, created_at);
CREATE INDEX IF NOT EXISTS idx_authorship_researcher ON authorship(researcher_id);
