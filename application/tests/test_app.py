from sentinel_app import create_app


def make_client(monkeypatch):
    monkeypatch.setenv("SENTINEL_APP_VERSION", "1.2.3-test")
    monkeypatch.setenv("SENTINEL_ENVIRONMENT", "blue")
    app = create_app()
    app.config["TESTING"] = True
    return app.test_client()


def test_health_endpoint_reports_healthy_and_release(monkeypatch):
    response = make_client(monkeypatch).get("/health")

    assert response.status_code == 200
    assert response.get_json() == {
        "status": "healthy",
        "service": "sentinel",
        "version": "1.2.3-test",
        "environment": "blue",
    }


def test_version_endpoint_reports_environment(monkeypatch):
    response = make_client(monkeypatch).get("/version")

    assert response.status_code == 200
    assert response.get_json()["version"] == "1.2.3-test"
    assert response.get_json()["environment"] == "blue"


def test_root_endpoint_is_available(monkeypatch):
    response = make_client(monkeypatch).get("/")

    assert response.status_code == 200
    assert response.get_json()["service"] == "sentinel"
