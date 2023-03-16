package VivohCache::Admin;

use nginx;

sub handler {

    my $r = shift;

    $r->send_http_header("text/html");
    return OK if $r->header_only;
    $pwd = `pwd`;
	$ls = `ls`;
    $r->print("$pwd\n<br>\n");
    $r->print("$ls\n<br>\n");
#    $r->print("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n");

    return OK;
}

1;
__END__
