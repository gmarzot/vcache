## Setup Steps

1. Install prerequisites (sudo apt install -y docker.io docker-compose)
1. Determine installation host hostname (e.g., vivoh-cache.vivoh.io)
1. Generate appropriate SSL keys/certs and cat all into etc/hitch/hitch-bundle.pem
1. Change nginx server hostname (perl -pi -e 's/home.marzot.net/vivoh.io/' etc/nginx/sites-enabled/vivoh-cache.cfg)
1. Start cache containers (docker-compose up or docker-compose up -d)

