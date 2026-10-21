#!/usr/bin/env bash
set -euo pipefail

PLUGIN_JAR="br.com.prova.idempiere_1.0.0.jar"

mkdir -p target
docker compose cp br.com.prova.idempiere/. idempiere:/tmp/prova-plugin
docker compose exec -T -u 1001 idempiere sh -lc '
  set -e
  mkdir -p /tmp/prova-plugin-build/classes
  find /tmp/prova-plugin-build/classes -type f -delete
  find /tmp/prova-plugin/src -name "*.java" -print0 \
    | xargs -0 javac --release 17 -cp "/opt/idempiere/plugins/*" \
        -d /tmp/prova-plugin-build/classes
  jar cfm /tmp/br.com.prova.idempiere_1.0.0.jar \
    /tmp/prova-plugin/META-INF/MANIFEST.MF \
    -C /tmp/prova-plugin-build/classes . \
    -C /tmp/prova-plugin OSGI-INF \
    -C /tmp/prova-plugin plugin.xml \
    -C /tmp/prova-plugin reports
'
docker compose cp "idempiere:/tmp/${PLUGIN_JAR}" "target/${PLUGIN_JAR}"

echo "Bundle criado em target/${PLUGIN_JAR}"
