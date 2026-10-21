#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "$0")/.." && pwd)"
test_dir="$(mktemp -d)"
trap 'rm -rf "$test_dir"' EXIT

javac -d "$test_dir" \
  "$repo_dir/br.com.prova.idempiere/src/br/com/prova/idempiere/domain/RequestRules.java" \
  "$repo_dir/br.com.prova.idempiere/test/br/com/prova/idempiere/domain/RequestRulesTest.java"

java -cp "$test_dir" br.com.prova.idempiere.domain.RequestRulesTest

