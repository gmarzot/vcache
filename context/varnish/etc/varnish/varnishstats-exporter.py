import redis
import logging
import datetime
import os
import subprocess
import time

redis = redis.Redis(host='vcache_redis', port=6379, db=0)

while True:
    stats_json = subprocess.check_output("/usr/bin/varnishstat -j; exit 0", stderr=subprocess.STDOUT, shell=True)
    redis.set("varnish_stats", stats_json)
    time.sleep(2)

