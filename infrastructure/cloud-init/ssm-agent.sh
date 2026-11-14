#!/usr/bin/env bash
set -euo pipefail

if ! snap list amazon-ssm-agent >/dev/null 2>&1; then
  snap install amazon-ssm-agent --classic
fi

systemctl enable --now snap.amazon-ssm-agent.amazon-ssm-agent.service
