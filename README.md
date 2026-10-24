# docker-caddy-proxy

Caddy 2 image for an HTTPS reverse proxy, built with [xcaddy](https://caddyserver.com/docs/build#docker).

Includes supported [DNS providers](https://github.com/caddy-dns) and
[Caddy Security](https://github.com/greenpau/caddy-security) for login and JWT
authorization. Versions are pinned in [modules.txt](modules.txt).
For Datadog, use Caddy's built-in [metrics](https://caddyserver.com/docs/metrics)
with the Agent's OpenMetrics integration.

## Run

Create a `Caddyfile`:

```caddyfile
app.example.com {
	reverse_proxy app:8080
}
```

Run on the same Docker network as your application:

```sh
docker run -d --name caddy-proxy --network app-network \
  -p 80:80 -p 443:443 -p 443:443/udp \
  -v "$PWD/Caddyfile:/etc/caddy/Caddyfile:ro" \
  -v caddy_data:/data \
  -v caddy_config:/config \
  ghcr.io/rochdev/docker-caddy-proxy:v2
```

## Build and test

```sh
docker build -t ghcr.io/rochdev/docker-caddy-proxy:v2 .
./tests/smoke.sh
```

GitHub Actions tests pull requests and publishes successful `v2` builds to GHCR
with `v2` and `sha-<commit>` tags. After the first publication, set the package
visibility to Public for anonymous pulls.
