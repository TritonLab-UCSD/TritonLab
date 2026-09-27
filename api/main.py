"""TritonLab API. Week 1 adds /recommend, /lab/{id}, and /draft."""

from fastapi import FastAPI

app = FastAPI(title="TritonLab API", version="0.1.0")


@app.get("/health")
def health() -> dict:
    return {"status": "ok"}
