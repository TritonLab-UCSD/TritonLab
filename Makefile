.PHONY: install lint test api app db-init dbt

install:
	pip install -r requirements-dev.txt

lint:
	ruff check .

test: lint
	pytest -q

api:
	uvicorn api.main:app --reload --port 8000

app:
	streamlit run frontend/app.py

db-init:
	python scripts/db_init.py

dbt:
	cd warehouse && dbt build
