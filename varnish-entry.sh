varnishd -d -p feature=+http2 -a /var/run/varnish.sock,PROXY,user=varnish,group=varnish,mode=660 -f /etc/varnish/default.vcl -s malloc,12G
