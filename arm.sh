for x in nginx varnish node-red; do
    ~/.docker/cli-plugins/docker-buildx build -t private-registry.vivoh.com/vcache-$x-arm64:0.0.1 ./docker-context/$x/ --platform linux/arm64
    docker push private-registry.vivoh.com/vcache-$x-arm64:0.0.1
done
