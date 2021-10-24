FROM caddy:builder AS builder

RUN xcaddy build \
    --with github.com/greenpau/caddy-authorize \
    --with github.com/caddy-dns/gandi

FROM caddy

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
