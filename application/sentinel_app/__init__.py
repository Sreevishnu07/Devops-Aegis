"""Sentinel demo application with deployment-aware health endpoints."""

import os
from flask import Flask, jsonify


def create_app() -> Flask:
    app = Flask(__name__)

    app.config["SENTINEL_APP_VERSION"] = os.getenv("SENTINEL_APP_VERSION", "0.0.0")
    app.config["SENTINEL_ENVIRONMENT"] = os.getenv("SENTINEL_ENVIRONMENT", "unknown")

    @app.get("/")
    def index():
        return jsonify(
            service="sentinel",
            message="Sentinel Blue-Green Deployment Platform",
            version=app.config["SENTINEL_APP_VERSION"],
            environment=app.config["SENTINEL_ENVIRONMENT"],
        )

    @app.get("/health")
    def health():
        return jsonify(
            status="healthy",
            service="sentinel",
            version=app.config["SENTINEL_APP_VERSION"],
            environment=app.config["SENTINEL_ENVIRONMENT"],
        ), 200

    @app.get("/version")
    def version():
        return jsonify(
            service="sentinel",
            version=app.config["SENTINEL_APP_VERSION"],
            environment=app.config["SENTINEL_ENVIRONMENT"],
        ), 200

    return app
