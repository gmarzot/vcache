## Setup Steps

1. Install prerequisites (sudo apt install -y docker.io docker-compose)
1. Determine installation host hostname (e.g., vivoh-cache.vivoh.io)
1. Generate appropriate SSL keys/certs and cat all into etc/hitch/hitch-bundle.pem
1. Change nginx server hostname (perl -pi -e 's/home.marzot.net/vivoh.io/' etc/nginx/sites-enabled/vivoh-cache.cfg)
1. Start cache containers (sudo docker-compose up or sudo docker-compose up -d)

**note:** docker-compse version <= 1.29 required. see https://github.com/docker/compose

**note:** you may need to make the run directory writable (chmod o+w run)
