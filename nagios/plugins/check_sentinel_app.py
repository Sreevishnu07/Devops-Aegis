#!/usr/bin/env python3
"""Nagios plugin: verify the local Sentinel app's health and environment identity."""

from __future__ import annotations

import argparse
import json
import sys
from urllib.error import HTTPError, URLError
from urllib.request import urlopen

OK = 0
WARNING = 1
CRITICAL = 2
UNKNOWN = 3


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--expected-environment", choices=("blue", "green"), required=True)
    parser.add_argument("--url", default="http://127.0.0.1:8000/health")
    parser.add_argument("--timeout", type=float, default=4.0)
    args = parser.parse_args()

    try:
        with urlopen(args.url, timeout=args.timeout) as response:
            if response.status != 200:
                print(f"SENTINEL APP CRITICAL - HTTP {response.status}")
                return CRITICAL
            payload = json.loads(response.read().decode("utf-8"))
    except (HTTPError, URLError, TimeoutError, json.JSONDecodeError, UnicodeDecodeError) as exc:
        print(f"SENTINEL APP CRITICAL - health request failed: {exc}")
        return CRITICAL
    except Exception as exc:  # Defensive plugin boundary: never emit a traceback to Nagios.
        print(f"SENTINEL APP UNKNOWN - unexpected check error: {exc}")
        return UNKNOWN

    environment = payload.get("environment")
    status = payload.get("status")
    version = payload.get("version")

    if status != "healthy":
        print(f"SENTINEL APP CRITICAL - status={status!r}")
        return CRITICAL
    if environment != args.expected_environment:
        print(
            "SENTINEL APP CRITICAL - environment mismatch: "
            f"expected={args.expected_environment}, actual={environment!r}"
        )
        return CRITICAL
    if not isinstance(version, str) or not version.strip():
        print("SENTINEL APP CRITICAL - version is missing")
        return CRITICAL

    print(f"SENTINEL APP OK - environment={environment} version={version}")
    return OK


if __name__ == "__main__":
    sys.exit(main())
