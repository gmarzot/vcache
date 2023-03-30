package VivohCache::Health;

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
		$redis = Redis->new(server => 'redis:6379',
					   reconnect => 60, every => 1000,
					   read_timeout => 2);

	}

	# should be parsing these from keys with glob - XXX
	my @keys = qw(host version uptime disk_total cpu_use_pct load_avg 
				mem_info disk_use_pct disk_use 
				client_sess cache_eff client_bw req_eff req_rate 
				upstream_bw upstream_req_rate);
	
	my @data = ();
	@data = $redis->mget(@keys);

	if (@data) {
		my %cache_health;
		@cache_health{@keys} = @data;
		$cache_health{'status'} = 'up';
		my $health = $json->encode(\%cache_health);
		$r->print($health);
		return OK;
	}
	return HTTP_INTERNAL_SERVER_ERROR;
}

1;
__END__
