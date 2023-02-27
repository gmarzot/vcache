vcl 4.1;

import std;
import var;

backend default {
#    .host = "127.0.0.1";
#    .port = "8888";
    .path = "/var/run/nginx.sock";
    .max_connections = 100;
    .probe = {
        .request =
            "HEAD / HTTP/1.1"
            "Host: localhost"
            "Connection: close"
            "User-Agent: Varnish Health Probe";
        .interval  = 10s;
        .timeout   = 5s;
        .window    = 5;
        .threshold = 3;
    }
}

sub vcl_recv {
    if (req.method == "OPTIONS") {
       return(synth(200));
    }
    if (req.http.host ~ "customer-gokzt9h2p9dpbdy7.cloudflarestream.com") {
            set req.http.host = "vivoh-cache.home.marzot.net";
            set req.url = "/cache/customer-gokzt9h2p9dpbdy7.cloudflarestream.com" + req.url;
    }
    #if (req.url ~ "(?i)\.(ts|mp4|mp3|m3u8|mpd)") {
       #unset req.http.Cookie;
       #set req.url = regsub(req.url, "\?[-_A-z0-9+()=%.&]*$", "");
     #  return (hash);
    #}
}
sub vcl_deliver {
    # Don't send cache tags related headers to the client
    # unset resp.http.url;
    # Uncomment the following line to NOT send the "Cache-Tags" header to the client (prevent using CloudFlare cache tags)
    unset resp.http.Cache-Tags;

    set resp.http.Access-Control-Allow-Local-Network = "true";

    if (req.http.Origin) {
       set resp.http.Access-Control-Allow-Origin = req.http.Origin;
    }

    if (obj.hits > 0) { # Add debug header to see if it's a HIT/MISS and the number of hits, disable when not needed
        set resp.http.X-Vivoh-Cache = "HIT";
    } else {
        set resp.http.X-Vivoh-Cache = "MISS";
    }
    # Please note that obj.hits behaviour changed in 4.0, now it counts per objecthead, not per object
    # and obj.hits may not be reset in some cases where bans are in use. See bug 1492 for details.
    # So take hits with a grain of salt
    set resp.http.X-Vivoh-Cache-Hits = obj.hits;
}

sub vcl_backend_response {
    if (beresp.status == 404) { 
       set beresp.ttl = 0s;
       return(deliver);
    }
    if (bereq.method != "OPTIONS") {
       if (bereq.url ~ "(?i)\.(m3u8|mpd)$") {
          set beresp.ttl = 1s;
          return(deliver);
       } else if (bereq.url ~ "(?i)\.(ts|mp4|mp3)$") {
          set beresp.ttl = 300s;
          return(deliver);
       }
    }
}

sub vcl_hash {
    if (req.method) {
        hash_data(req.method);
    }
    if (req.url ~ "(?i)\.(ts|mp4|mp3|m3u8|mpd)") {
        var.set("url_path", regsub(req.url, "\?[-_A-z0-9+()=%.&]*$", ""));
    } else {
        var.set("url_path", req.url);
    }
    hash_data(var.get("url_path"));
    if (req.http.host) {
        hash_data(req.http.host);
    } else {
        hash_data(server.ip);
    }
    return (lookup);
}

sub vcl_synth {
    if (req.method == "OPTIONS") {
        set resp.http.Access-Control-Allow-Headers = "Content-Type,Content-Length,Authorization,Accept,X-Requested-With";
        set resp.http.Access-Control-Allow-Methods = "GET,HEAD,OPTIONS";
        set resp.http.Access-Control-Allow-Local-Network = "true";
        set resp.http.Allow-Credentials = "true";
        set resp.http.ETag = "123456";
        set resp.http.Access-Control-Allow-Origin = req.http.Origin;
        return(deliver);
    }
}