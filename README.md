## Setup Steps

1. Install prerequisites (sudo apt install -y docker.io docker-compose)
1. Determine desired cache hostname supplied start .env (e.g., cache-01.demo.vivoh.net) 
1. Generate appropriate SSL keys/certs and add to ./etc/nginx/pki (e.g., cache-cert.pem cache-cert.key )
1. Build the images (sudo docker-compose build --pull) (**note:** this can take several minutes)
1. Start cache containers: ./vivoh-cache-start (requires sudo priviledges)

**note:** docker-compose version >= 1.29 required. see https://github.com/docker/compose
**note:** cache frontend comes up on port 443 by default, and supports TLS 1.2 and 1.3 only
**note:** cache supplies a custom response header: x-vivoh-cache: MISS| HIT
**note:** standard URL path for accesing upstream video source: https://<cache-hostname>/cache/<upstream-host>/<upstream-path-to-manifest> 
**note:** analytic dashoard is available at https://<cache-hostname>:8443/admin
**note:** health api endpoint is available at https://<cache-hostname>:8443/health

## Test

run this twice and observe MISS then HIT

curl -v  "https://cache-01.vivoh.net/cache/releases.vivoh.com/videos/adena.mp4" -o /dev/null 2>&1 | grep "^[\<\>]" | grep -i vivoh-cache



