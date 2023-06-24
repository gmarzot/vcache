#!/bin/sh

# wait for vcache_mgr_agent to complete config template resolution
while [ ! -f /var/run/.vcache_ready ]; do
	echo "[nginx-entrypoint] waiting for initial config setup..."
	sleep 2
done

exit 0
