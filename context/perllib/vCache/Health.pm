package vCache::Health;
use Socket;
use nginx;
use Redis;
my $redis;

use JSON;
my $json = JSON->new->utf8->canonical;

# should be parsing these from keys with glob - XXX
my @keys = qw(
host version client_sess cache_eff_pct client_bw req_eff_pct req_rate upstream_bw upstream_req_rate
uptime cpu_use_pct cpu_load_avg mem_total mem_use mem_use_pct disk_total disk_use disk_use_pct 
	);
	
sub handler {
    my $r = shift;
    $r->send_http_header("application/json");
    return OK if $r->header_only;

	if (!defined $redis) {
		$redis = Redis->new(server => 'vcache_redis:6379',
							reconnect => 60, every => 1000,
							read_timeout => 2);
		return HTTP_INTERNAL_SERVER_ERROR unless defined($redis);
	}

    my %cache_health = $redis->hgetall("vcache_stats");;

    if (%cache_health) {
		$cache_health{'status'} = 'up';
		my $host = $cache_health{"hostname"};
		# XXX this does not add any useful ip info
		if (0 and defined($host) and length($host)) {
			my $ipv4_addr = gethostbyname($host);
			if (defined($ipv4_addr) and length($ipv4_addr)) {
				$ipv4_addr = inet_ntoa($ipv4_addr);
			}
			$cache_health{"ipv4_addr"} = $ipv4_addr;
		}
		my $health = $json->encode(\%cache_health);
		$r->print($health);

		return OK;
	}
	
	return HTTP_INTERNAL_SERVER_ERROR;
}

1;
__END__
