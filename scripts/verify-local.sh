#!/usr/bin/env bash
set -euo pipefail

docker compose ps
curl -kfsS --max-time 20 https://127.0.0.1:8443/webui/ >/dev/null
docker compose exec -T postgres \
  psql -v ON_ERROR_STOP=1 -U adempiere -d idempiere \
  < migration/postgresql/verify.sql
bash scripts/test-rules.sh

echo "Ambiente local: OK"
