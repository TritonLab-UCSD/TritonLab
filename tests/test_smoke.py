from fastapi.testclient import TestClient

from api.main import app


def test_health() -> None:
    client = TestClient(app)
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


def test_packages_import() -> None:
    import entity_resolution  # noqa: F401
    import ingestion  # noqa: F401
    import llm  # noqa: F401
    import matching  # noqa: F401
    import orchestration  # noqa: F401
