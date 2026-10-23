#!/usr/bin/env bash
set -euo pipefail

docker compose ps
curl -kfsS --max-time 20 https://127.0.0.1:8443/webui/ >/dev/null
docker compose exec -T postgres \
  psql -v ON_ERROR_STOP=1 -U adempiere -d idempiere \
  < migration/postgresql/verify.sql

repo_dir="$(cd "$(dirname "$0")/.." && pwd)"
test_dir="$(mktemp -d)"
trap 'rm -rf "$test_dir"' EXIT

javac -d "$test_dir" \
  "$repo_dir/br.com.prova.idempiere/src/br/com/prova/idempiere/domain/RequestRules.java" \
  "$repo_dir/br.com.prova.idempiere/test/br/com/prova/idempiere/domain/RequestRulesTest.java"

java -cp "$test_dir" br.com.prova.idempiere.domain.RequestRulesTest

echo "Ambiente local: OK"
