#!/usr/bin/env bash
set -e

mkdir -p /app/artifacts/models /app/artifacts/encoders /app/logs

exec "$@"
