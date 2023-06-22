FROM nginx:1.25.0

RUN set -x \
    && apt-get update \
    && apt-get install --no-install-recommends --no-install-suggests -y gnupg1 ca-certificates \
    && \
    NGINX_GPGKEY=573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62; \
    NGINX_GPGKEY_PATH=/usr/share/keyrings/nginx-archive-keyring.gpg; \
    export GNUPGHOME="$(mktemp -d)"; \
    found=''; \
    for server in \
        hkp://keyserver.ubuntu.com:80 \
        pgp.mit.edu \
    ; do \
        echo "Fetching GPG key $NGINX_GPGKEY from $server"; \
		gpg1 --keyserver "$server" --keyserver-options timeout=10 --recv-keys "$NGINX_GPGKEY" && found=yes && break; \
    done; \
    test -z "$found" && echo >&2 "error: failed to fetch GPG key $NGINX_GPGKEY" && exit 1; \
    gpg1 --export "$NGINX_GPGKEY" > "$NGINX_GPGKEY_PATH" ; \
    rm -rf "$GNUPGHOME"; \
    apt-get remove --purge --auto-remove -y gnupg1 && rm -rf /var/lib/apt/lists/* \
    && dpkgArch="$(dpkg --print-architecture)" \
    && nginxPackages=" \
        nginx=${NGINX_VERSION}-${PKG_RELEASE} \
        nginx-module-xslt=${NGINX_VERSION}-${PKG_RELEASE} \
        nginx-module-geoip=${NGINX_VERSION}-${PKG_RELEASE} \
        nginx-module-image-filter=${NGINX_VERSION}-${PKG_RELEASE} \
        nginx-module-perl=${NGINX_VERSION}-${PKG_RELEASE} \
        nginx-module-njs=${NGINX_VERSION}+${NJS_VERSION}-${PKG_RELEASE} \
    " \
    && case "$dpkgArch" in \
        amd64|arm64) \
# arches officialy built by upstream
            echo "deb [trusted=yes] https://nginx.org/packages/mainline/debian/ bullseye nginx" >> /etc/apt/sources.list.d/nginx.list \
            && apt-get update \
            ;; \
        *) \
# we're on an architecture upstream doesn't officially build for
# let's build binaries from the published source packages
            echo "deb-src https://nginx.org/packages/mainline/debian/ bullseye nginx" >> /etc/apt/sources.list.d/nginx.list \
            \
# new directory for storing sources and .deb files
            && tempDir="$(mktemp -d)" \
            && chmod 777 "$tempDir" \
# (777 to ensure APT's "_apt" user can access it too)
            \
# save list of currently-installed packages so build dependencies can be cleanly removed later
            && savedAptMark="$(apt-mark showmanual)" \
            \
# build .deb files from upstream's source packages (which are verified by apt-get)
            && apt-get update \
            && apt-get build-dep -y nginx-module-perl=${NGINX_VERSION}-${PKG_RELEASE} \
            && ( \
                cd "$tempDir" \
                && DEB_BUILD_OPTIONS="nocheck parallel=$(nproc)" \
                    apt-get source --compile nginx-module-perl=${NGINX_VERSION}-${PKG_RELEASE} \
            ) \
# we don't remove APT lists here because they get re-downloaded and removed later
            \
# reset apt-mark's "manual" list so that "purge --auto-remove" will remove all build dependencies
# (which is done after we install the built packages so we don't have to redownload any overlapping dependencies)
            && apt-mark showmanual | xargs apt-mark auto > /dev/null \
            && { [ -z "$savedAptMark" ] || apt-mark manual $savedAptMark; } \
            \
# create a temporary local APT repo to install from (so that dependency resolution can be handled by APT, as it should be)
            && ls -lAFh "$tempDir" \
            && ( cd "$tempDir" && dpkg-scanpackages . > Packages ) \
            && grep '^Package: ' "$tempDir/Packages" \
            && echo "deb [ trusted=yes ] file://$tempDir ./" > /etc/apt/sources.list.d/temp.list \
# work around the following APT issue by using "Acquire::GzipIndexes=false" (overriding "/etc/apt/apt.conf.d/docker-gzip-indexes")
#   Could not open file /var/lib/apt/lists/partial/_tmp_tmp.ODWljpQfkE_._Packages - open (13: Permission denied)
#   ...
#   E: Failed to fetch store:/var/lib/apt/lists/partial/_tmp_tmp.ODWljpQfkE_._Packages  Could not open file /var/lib/apt/lists/partial/_tmp_tmp.ODWljpQfkE_._Packages - open (13: Permission denied)
            && apt-get -o Acquire::GzipIndexes=false update \
            ;; \
    esac \
    \
    && apt-get install --no-install-recommends --no-install-suggests -y \
                        $nginxPackages \
                        gettext-base \
                        curl \
						wget \
						git \
						build-essential \
						libpcre2-dev \
						zlib1g-dev \
						libredis-perl \
						libjson-perl \
						libdatetime-perl \
						libdevel-dumpvar-perl \
						libgoogle-protocolbuffers-perl
RUN git clone https://github.com/yaoweibin/ngx_http_substitutions_filter_module.git
RUN wget https://nginx.org/download/nginx-1.25.0.tar.gz
RUN tar xzvf nginx-1.25.0.tar.gz
RUN cd nginx-1.25.0 && ./configure --with-compat --add-dynamic-module=../ngx_http_substitutions_filter_module && make modules && cp objs/ngx_http_subs_filter_module.so /etc/nginx/modules/

RUN apt-get remove --purge --auto-remove -y && rm -rf /var/lib/apt/lists/* /etc/apt/sources.list.d/nginx.list \
    \
# if we have leftovers from building, let's purge them (including extra, unnecessary build deps)
    && if [ -n "$tempDir" ]; then \
        apt-get purge -y --auto-remove \
        && rm -rf "$tempDir" /etc/apt/sources.list.d/temp.list; \
    fi

ARG SERVICE_ROLE
COPY ./perllib /var/lib/nginx/perllib
COPY ./etc/nginx/modules-enabled /etc/nginx/modules-enabled
COPY ./etc/nginx/pki /etc/nginx/pki
COPY ./etc/nginx/*.conf /etc/nginx/temp/
COPY ./etc/nginx/sites-enabled/* /etc/nginx/temp/
RUN mkdir /etc/nginx/sites-enabled
RUN if [ "$SERVICE_ROLE" = "frontend" ]; then \
        cp /etc/nginx/temp/nginx-fe.conf /etc/nginx/nginx.conf; \
        cp /etc/nginx/temp/frontend.cfg.tmpl /etc/nginx/sites-enabled/; \
    elif [ "$SERVICE_ROLE" = "backend" ]; then \
        cp /etc/nginx/temp/nginx-be.conf /etc/nginx/nginx.conf; \
        cp /etc/nginx/temp/backend.cfg /etc/nginx/sites-enabled/; \
    fi
VOLUME /etc/nginx
COPY ./nginx-wait-config.sh /docker-entrypoint.d/nginx-wait-config.sh