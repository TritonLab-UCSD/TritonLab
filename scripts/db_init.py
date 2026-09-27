"""Apply every SQL migration in db/migrations in filename order."""

import os
from pathlib import Path

import psycopg
from dotenv import load_dotenv

load_dotenv()

MIGRATIONS = Path(__file__).resolve().parent.parent / "db" / "migrations"


def main() -> None:
    url = os.environ["DATABASE_URL"]
    with psycopg.connect(url, autocommit=True) as conn:
        for path in sorted(MIGRATIONS.glob("*.sql")):
            print(f"Applying {path.name}")
            conn.execute(path.read_text())
    print("Done.")


if __name__ == "__main__":
    main()
