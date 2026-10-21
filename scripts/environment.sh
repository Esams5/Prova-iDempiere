#!/usr/bin/env bash
set -euo pipefail

ACTION="${1:-status}"

case "$ACTION" in
  start)
    docker compose up -d
    ;;
  stop)
    docker compose stop
    ;;
  status)
    docker compose ps
    ;;
  logs)
    docker compose logs --tail=200 -f idempiere
    ;;
  *)
    echo "Uso: $0 {start|stop|status|logs}" >&2
    exit 2
    ;;
esac
