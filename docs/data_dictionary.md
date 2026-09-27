# Data Dictionary and Contracts

Finalize together on Day 1. Every layer depends on these tables. Change them only through a PR that all three people approve.

## Tables

### institution
| Column | Type | Notes |
|---|---|---|
| institution_id | serial PK | |
| name | text | "UC San Diego", "Salk Institute", ... |
| type | text | `ucsd` or `institute` |

### department
| Column | Type | Notes |
|---|---|---|
| department_id | serial PK | |
| institution_id | FK | |
| name | text | |
| website | text | |

### researcher
| Column | Type | Notes |
|---|---|---|
| researcher_id | serial PK | canonical id after entity resolution |
| full_name | text | |
| title | text | Professor, Assistant Professor, ... |
| email | text | from public faculty pages only |
| department_id | FK | |
| openalex_id | text | |
| nih_pi_id | text | |
| orcid | text | |

### lab
| Column | Type | Notes |
|---|---|---|
| lab_id | serial PK | |
| name | text | |
| pi_researcher_id | FK | not null |
| website | text | |
| description | text | |

### paper
| Column | Type | Notes |
|---|---|---|
| paper_id | serial PK | |
| openalex_id | text unique | |
| title | text | |
| abstract | text | reconstructed from OpenAlex inverted index |
| publication_date | date | |
| venue | text | |
| topics | text[] | |

### authorship
| Column | Type | Notes |
|---|---|---|
| paper_id | FK | |
| researcher_id | FK | |
| author_position | int | |

### grant_award
| Column | Type | Notes |
|---|---|---|
| grant_id | serial PK | |
| source | text | `nih` or `nsf` |
| award_number | text | |
| pi_researcher_id | FK | |
| title | text | |
| abstract | text | |
| amount_usd | numeric | |
| start_date / end_date | date | |

### lab_features
| Column | Type | Notes |
|---|---|---|
| lab_id | FK PK | |
| undergrad_prob | real | 0 to 1 |
| undergrad_label | text | `likely`, `possible`, `unclear` |
| activity_score | real | |
| activity_breakdown | jsonb | component scores |
| updated_at | timestamptz | |

### embedding
| Column | Type | Notes |
|---|---|---|
| entity_type | text | `lab`, `paper`, `student` |
| entity_id | int | |
| model | text | model name used |
| embedding | vector | dimension fixed once the model is chosen (Week 2) |

### student_profile
| Column | Type | Notes |
|---|---|---|
| student_id | serial PK | |
| interests | text | |
| resume_text | text | |
| courses | text[] | |
| skills | text[] | |
| created_at | timestamptz | |

### interaction
| Column | Type | Notes |
|---|---|---|
| interaction_id | serial PK | |
| student_id | FK | |
| lab_id | FK | |
| type | text | `view`, `save`, `good_fit`, `not_for_me`, `outreach_sent`, `reply` |
| created_at | timestamptz | |

## Contracts (guarantees between layers)

- `lab` has one row per lab, a non-null PI, and at least one linked paper for any lab shown in the app.
- `paper.abstract` is non-null for any paper used in embeddings or LLM prompts.
- `lab_features` is refreshed after every pipeline run.
- Raw source data lands in the `raw` schema. Cleaned tables live in `public`. The app reads only from `public`.
