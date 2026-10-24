# syntax=docker/dockerfile:1
ARG CADDY_VERSION=2.11.7

FROM caddy:${CADDY_VERSION}-builder AS builder

COPY modules.txt /tmp/modules.txt
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    set -eu; \
    set --; \
    while IFS= read -r module; do \
        case "$module" in ''|'#'*) continue ;; esac; \
        set -- "$@" --with "$module"; \
    done < /tmp/modules.txt; \
    xcaddy build --output /usr/bin/caddy "$@"

FROM caddy:${CADDY_VERSION}

LABEL org.opencontainers.image.source="https://github.com/rochdev/docker-caddy-proxy"

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
