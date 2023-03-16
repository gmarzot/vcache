## Setup Steps

1. Install prerequisites (sudo apt install -y docker.io docker-compose)
1. Determine installation cache host hostname (e.g., vivoh-cache.vivoh.io)
1. Generate appropriate SSL keys/certs and add to ./nginx/pki (e.g., vivoh-cache.vivoh.io.pub vivoh-cache.vivoh.io.key)
1. Add the key paths above to ./etc/nginx/sites-enabled/vivoh-cache-frontend.cfg
1. Change nginx server hostname (perl -pi -e 's/home.marzot.net/vivoh.io/' etc/nginx/sites-enabled/vivoh-cache-*.cfg)
1. Build the images (sudo docker-compose build --pull)
1. Start cache containers (sudo docker-compose up or sudo docker-compose up -d)

**note:** docker-compse version >= 1.29 required. see https://github.com/docker/compose

**note:** you may need to make the run directory writable (chmod o+w run)

**note:** cache front end now comes up on port 443 and supports TLS 1.2 and 1.3 only

## Test

time curl -v  "https://vivoh-cache.home.marzot.net/cache/vivoh-cache.vivoh.io/cache/teststream.rampecdn.com/ramptv/video/stream-12072016/0500026413_player.hls-500k.split.44.ts" -o test-2.ts 2>&1 | grep "^[\<\>]"

### Expected output

**note:** cache x-vivoh-cache: MISS and subsequent HIT

gmarzot@typhoon:~$ time curl -v  "https://vivoh-cache.home.marzot.net/cache/teststream.rampecdn.com/ramptv/video/stream-12072016/0500026413_player.hls-500k.split.44.ts" -o test-1.ts 2>&1 | grep "^[\<\>]"
> GET /cache/vivoh-cache.home.marzot.net/cache/teststream.rampecdn.com/ramptv/video/stream-12072016/0500026413_player.hls-500k.split.44.ts HTTP/2
> Host: vivoh-cache.home.marzot.net
> user-agent: curl/7.81.0
> accept: */*
>
< HTTP/2 200
< server: nginx/1.23.3
< date: Thu, 16 Mar 2023 15:55:49 GMT
< content-type: video/MP2T
< content-length: 408712
< last-modified: Wed, 26 Apr 2017 13:09:50 GMT
< etag: "1ec0018c35610fee841ad3ed243ba190"
< cache-control: max-age=86400
< x-cache: Miss from cloudfront
< x-amz-cf-pop: BOS50-C3
< x-amz-cf-id: SvcIC1y5j4okLhzPawbFTPmpZXnqoJd-dgCky-1QZ3gZK5ihMX7C1g==
< x-varnish: 5
< x-varnish: 32782 32776
< age: 75
< via: 1.1 a401d3cb0c7ffe12c21e6f851d6fb426.cloudfront.net (CloudFront), 1.1 6ed682cfcca8 (Varnish/7.2), 1.1 6ed682cfcca8 (Varnish/7.2)
< accept-ranges: bytes
< access-control-allow-local-network: true
< access-control-allow-origin: *
< x-vivoh-cache: HIT
< x-vivoh-cache-hits: 5
<

real    0m0.048s
user    0m0.047s
sys     0m0.000s
gmarzot@typhoon:~$ time curl -v  "https://vivoh-cache.home.marzot.net/cache/teststream.rampecdn.com/ramptv/video/stream-12072016/0500026413_player.hls-500k.split.37.ts" -o test-2.ts 2>&1 | grep "^[\<\>]"
> GET /cache/vivoh-cache.home.marzot.net/cache/teststream.rampecdn.com/ramptv/video/stream-12072016/0500026413_player.hls-500k.split.37.ts HTTP/2
> Host: vivoh-cache.home.marzot.net
> user-agent: curl/7.81.0
> accept: */*
>
< HTTP/2 200
< server: nginx/1.23.3
< date: Thu, 16 Mar 2023 15:56:12 GMT
< content-type: video/MP2T
< content-length: 224472
< last-modified: Wed, 26 Apr 2017 13:09:43 GMT
< etag: "8df32c9e054ded93f6f5a728e0efa103"
< cache-control: max-age=86400
< x-cache: Miss from cloudfront
< x-amz-cf-pop: BOS50-C3
< x-amz-cf-id: HhTD5zQLtauezAKB2C696rSDFQ-LT50aLXk5BCwl7EiJBRXOUtmjjg==
< x-varnish: 32784
< x-varnish: 12
< age: 0
< via: 1.1 e9286f0473f98fa5117acbf7d8238c90.cloudfront.net (CloudFront), 1.1 6ed682cfcca8 (Varnish/7.2), 1.1 6ed682cfcca8 (Varnish/7.2)
< accept-ranges: bytes
< access-control-allow-local-network: true
< access-control-allow-origin: *
< x-vivoh-cache: MISS
<

real    0m0.530s
user    0m0.047s
sys     0m0.000s
gmarzot@typhoon:~$ time curl -v  "https://vivoh-cache.home.marzot.net/cache/vivoh-cache.home.marzot.net/cache/teststream.rampecdn.com/ramptv/video/stream-12072016/0500026413_player.hls-500k.split.37.ts" -o test-2.ts 2>&1 | grep "^[\<\>]"
> GET /cache/vivoh-cache.home.marzot.net/cache/teststream.rampecdn.com/ramptv/video/stream-12072016/0500026413_player.hls-500k.split.37.ts HTTP/2
> Host: vivoh-cache.home.marzot.net
> user-agent: curl/7.81.0
> accept: */*
>
< HTTP/2 200
< server: nginx/1.23.3
< date: Thu, 16 Mar 2023 15:56:16 GMT
< content-type: video/MP2T
< content-length: 224472
< last-modified: Wed, 26 Apr 2017 13:09:43 GMT
< etag: "8df32c9e054ded93f6f5a728e0efa103"
< cache-control: max-age=86400
< x-cache: Miss from cloudfront
< x-amz-cf-pop: BOS50-C3
< x-amz-cf-id: HhTD5zQLtauezAKB2C696rSDFQ-LT50aLXk5BCwl7EiJBRXOUtmjjg==
< x-varnish: 32784
< x-varnish: 14 13
< age: 3
< via: 1.1 e9286f0473f98fa5117acbf7d8238c90.cloudfront.net (CloudFront), 1.1 6ed682cfcca8 (Varnish/7.2), 1.1 6ed682cfcca8 (Varnish/7.2)
< accept-ranges: bytes
< access-control-allow-local-network: true
< access-control-allow-origin: *
< x-vivoh-cache: HIT
< x-vivoh-cache-hits: 1
<

real    0m0.047s
user    0m0.042s
sys     0m0.005s
gmarzot@typhoon:~$ diff test-1.ts test-2.ts
