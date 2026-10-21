#!/usr/bin/env bash
set -euo pipefail

docker compose exec -T postgres \
  psql -v ON_ERROR_STOP=1 -U adempiere -d idempiere \
  < migration/postgresql/001_prova_request.sql

docker compose exec -T postgres \
  psql -v ON_ERROR_STOP=1 -U adempiere -d idempiere \
  < migration/postgresql/verify.sql
