package vCache::Health;
use nginx;
use Redis;
my $redis;

use JSON;
my $json = JSON->new->utf8->canonical;

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

    my %cache_health = $redis->hgetall("vcache:stats");;

    if (%cache_health) {
		$cache_health{'status'} = 'up';
		my $host = $cache_health{"hostname"};
		my $health = $json->encode(\%cache_health);
		$r->print($health);

		return OK;
	}
	
	return HTTP_INTERNAL_SERVER_ERROR;
}

1;
__END__
