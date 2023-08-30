import redis
import logging
import datetime
import os
import subprocess
import time

redis = redis.Redis(host='vcache_redis', port=6379, db=0)
vcl_reload = 'varnish::vcl_reload'
stats = 'varnish::stats'

while True:
    # get stats and save in redis
    stats_json = subprocess.check_output("/usr/bin/varnishstat -j; exit 0", stderr=subprocess.STDOUT, shell=True)
    redis.set(stats, stats_json)
    # monitor flag to reload vcl
    if (redis.exists(vcl_reload))
        try:
            print(f"VCL reload: running...")
            subprocess.run(['/usr/local/bin/vcl-reload'], check=True)
            print(f"VCL reload: success")
            redis.delete(vcl_reload)
        except subprocess.CalledProcessError as e:
            print(f"VCL reload: error: {e}")
    # loop forever
    time.sleep(5)

