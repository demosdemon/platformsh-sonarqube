#!/usr/bin/env bash

set -e

if ! command -v jq >/dev/null 2>&1; then
  echo 'unable to locate `jq`!' >&2
  exit 127
fi

database_username=$(echo $PLATFORM_RELATIONSHIPS | base64 -d | jq -r '.database[].username')
database_password=$(echo $PLATFORM_RELATIONSHIPS | base64 -d | jq -r '.database[].password')
database_url=$(echo $PLATFORM_RELATIONSHIPS | base64 -d | jq -r '.database[] | "postgresql://\(.host):\(.port)/\(.path)"')

declare -a sq_opts

for key in "${!sonar@}"; do
  sq_opts+=("-D${key}=${!key}")
done

echo "$PLATFORM_RELATIONSHIPS"

exec java -jar sonarqube/lib/sonar-application-$SONAR_VERSION.jar \
  -Dsonar.log.console=true \
  -Dsonar.web.port=$PORT \
  -Dsonar.updatecenter.activate=false \
  -Dsonar.jdbc.username="$database_username" \
  -Dsonar.jdbc.password="$database_password" \
  -Dsonar.jdbc.url="jdbc:$database_url" \
  -Dsonar.web.javaAdditionalOpts="$SONARQUBE_WEB_JVM_OPTS -Djava.security.egd=file:/dev/./urandom" \
  "${sq_opts[@]}"
