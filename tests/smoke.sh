#!/bin/bash
# Run against a locally built image; IMAGE_NAME overrides the default tag.
set -euo pipefail

cd "$(dirname "$0")/.."
image="${IMAGE_NAME:-ghcr.io/rochdev/caddy-proxy:v2}"

docker run --rm "$image" caddy version
modules="$(docker run --rm "$image" caddy list-modules --packages)"
# Match source packages: a provider's module ID can differ from its repository.
while IFS= read -r module; do
  case "$module" in ''|'#'*|github.com/libdns/*) continue ;; esac
  package="${module%@*}"
  printf '%s\n' "$modules" | awk -v package="$package" \
    '$2 == package { found = 1; print } END { exit !found }'
done < modules.txt

docker run --rm "$image" caddy validate --config /etc/caddy/Caddyfile --adapter caddyfile
docker run --rm -v "$PWD/tests/Caddyfile:/tmp/Caddyfile:ro" \
  "$image" caddy validate --config /tmp/Caddyfile --adapter caddyfile

# Exercise the proxy and metrics without publishing ports or contacting services.
docker run --rm -v "$PWD/tests/Caddyfile:/tmp/Caddyfile:ro" \
  --entrypoint sh "$image" -ec '
    caddy run --config /tmp/Caddyfile --adapter caddyfile &
    pid=$!
    trap "kill $pid; wait $pid || true" EXIT
    ready=false
    for attempt in 1 2 3 4 5 6 7 8 9 10; do
      if wget -qO- http://localhost:8080 2>/dev/null | grep -Fx "proxy smoke test"; then
        ready=true
        break
      fi
      sleep 1
    done
    "$ready"
    wget -qO- http://localhost:9180/metrics | grep -q caddy_http_requests_total
  '
