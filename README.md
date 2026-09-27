# TritonLab

TritonLab helps UC San Diego undergraduates find research labs that fit them. Students enter their interests, resume, and courses, and TritonLab recommends labs, explains why each one fits, shows whether the lab likely takes undergrads and is actively funded, summarizes its recent papers in plain language, and helps draft a personalized outreach email.

## Team

See [docs/team.md](docs/team.md) for roles and the weekly rotation.

## Architecture

1. **Ingestion** (`ingestion/`): connectors for OpenAlex, NIH/NSF grants, and faculty/lab pages.
2. **Warehouse** (`warehouse/`): dbt models and data tests on Postgres.
3. **Entity resolution** (`entity_resolution/`): links the same researcher across sources.
4. **Matching** (`matching/`): embeddings, retrieval, ranking, classifiers, evaluation.
5. **LLM** (`llm/`): paper explainer, fit explanations, outreach drafts, guardrails, evals.
6. **App** (`api/`, `frontend/`): FastAPI backend and Streamlit frontend.
7. **Orchestration** (`orchestration/`): Dagster jobs and schedules.

## Quickstart

```bash
git clone https://github.com/<org>/tritonlab.git
cd tritonlab
python -m venv .venv && source .venv/bin/activate   # Windows: .venv\Scripts\activate
pip install -r requirements-dev.txt
cp .env.example .env        # then fill in your keys
make test                   # lint + tests
make api                    # FastAPI at http://localhost:8000/docs
make app                    # Streamlit at http://localhost:8501
```

Apply the database schema (after setting `DATABASE_URL` in `.env`):

```bash
make db-init
```

## Contributing

Read [CONTRIBUTING.md](CONTRIBUTING.md) before opening your first pull request.
