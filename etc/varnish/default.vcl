vcl 4.1;

import std;
import var;
import re;
import cookie;
import blob;
import crypto;
import digest;

backend default {
    .path = "/var/run/nginx-backend.sock";
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

acl purge_acl {
   "localhost";
}

sub vcl_init {
        new query_str_regex = re.regex("^([^\?]*)(\?.*)?$");
        new vimeo_range_regex = re.regex("^([^\?]*\.mp4)\?.*(range=\d+-\d+).*$");
        new manifest_path_regex = re.regex("\.(mpd|m3u8)$");
        new segment_path_regex = re.regex("\.(ts|mp3|mp4)$");
        new media_path_regex = re.regex("\.(mpd|m3u8|ts|mp3|mp4)");
        new jwt_value_regex = re.regex("^([^\.]+)\.([^\.]+)\.([^\.]+)$");
        new v = crypto.verifier(sha256,std.fileread("/etc/varnish/jwtRS256.key.pub"));
}

sub validate_auth_jwt {
      var.set("auth_jwt", cookie.get("by"));
      if (jwt_value_regex.match(var.get("auth_jwt"))) {       
         var.set("auth_jwt_hdr", jwt_value_regex.backref(1));
         var.set("auth_jwt_pld", jwt_value_regex.backref(2));
         var.set("auth_jwt_sig", jwt_value_regex.backref(3));
      } else {
         return(synth(400, "bad JWT format"));  
      }
      # decode JWT header
      var.set("auth_jwt_hdr_decoded", digest.base64url_decode(var.get("auth_jwt_hdr")));
      var.set("auth_jwt_typ", regsub(var.get("auth_jwt_hdr_decoded"),{"^.*?"typ"\s*:\s*"(\w+)".*?$"},"\1"));
      var.set("auth_jwt_alg", regsub(var.get("auth_jwt_hdr_decoded"),{"^.*?"alg"\s*:\s*"(\w+)".*?$"},"\1"));

      if(var.get("auth_jwt_typ") != "JWT") {
         return(synth(400, "unrecognized JWT type: " + var.get("auth_jwt_typ")));
      }
      if(var.get("auth_jwt_alg") != "RS256") {
         return(synth(400, "unsupported JWT sig algorithm: " + var.get("auth_jwt_alg")));
      }

      v.reset();  // need this if request restart
      v.update(var.get("auth_jwt_hdr") + "." + var.get("auth_jwt_pld"));

      if (!v.valid(blob.decode(BASE64URLNOPAD, encoded=var.get("auth_jwt_sig")))) {
         return(synth(403, "invalid " + var.get("auth_jwt_typ") + " " + var.get("auth_jwt_alg") + " signature [" + var.get("auth_jwt_sig") + "]"));
      }
 }

sub vcl_recv {
    # short-circuit pre-flight OPTIONS requests
    if (req.method == "OPTIONS") {
       return(synth(200));
    }
    # XXX need to allow purge from container cluster/mgmt
    if (req.method == "PURGE") {
       if (!client.ip ~ purge_acl) {
          return(synth(405,"method not allowed: PURGE"));
       }
       return (purge);
    }

    cookie.parse(req.http.cookie);
    # if Vivoh auth token present - validate JWT - XXX suggest more unique cookie name
    if(cookie.isset("by")) {
       call validate_auth_jwt;
       return(hash);
    }
    # only cache supported methods for video media - XXX add content type as well url patter - derive from config
    if ((req.method == "GET" || req.method == "HEAD") && query_str_regex.match(req.url) && media_path_regex.match(query_str_regex.backref(1))) {
       return(hash);
    }
}

sub vcl_deliver {
    # prevent using CloudFlare cache tags
    unset resp.http.Cache-Tags;
    # satisfy PNA pre-flight requirements
    set resp.http.Access-Control-Allow-Local-Network = "true";
    # promiscuously allow content delivered from cache to be included in request origin 
    if (req.http.origin) {
       set resp.http.Access-Control-Allow-Origin = req.http.origin;
    } else {
       set resp.http.Access-Control-Allow-Origin = "*";
    }
    # track HIT/MISS status in response header
    if (obj.hits > 0) {
        set resp.http.X-Vivoh-Cache = "HIT";
        set resp.http.X-Vivoh-Cache-Hits = obj.hits;
    } else {
        set resp.http.X-Vivoh-Cache = "MISS";
    }
}

sub vcl_backend_response {
    # do not cache 404's
    if (beresp.status == 404) { 
       set beresp.ttl = 0s;
       return(deliver);
    }
    if (bereq.method != "OPTIONS") {
       if (bereq.url ~ "(?i)\.(m3u8|mpd)(\?|$)") {
          set beresp.ttl = 1s;
          return(deliver);
       } else if (bereq.url ~ "(?i)\.(ts|mp3|mp4)(\?|$)") {
          set beresp.ttl = 300s;
          return(deliver);
       }
    }
}

sub vcl_hash {
    if (req.method) {
        hash_data(req.method);
    }
    query_str_regex.match(req.url);
    # cache key should include vimeo non-standard range query parameters (XXX is this redally true)
    # for typical video content, the entire query string is stripped
    if (vimeo_range_regex.match(req.url)) {
        var.set("url_path", vimeo_range_regex.backref(1) + "?" + vimeo_range_regex.backref(2));
    } else if (media_path_regex.match(query_str_regex.backref(1))) {
        var.set("url_path", query_str_regex.backref(1));
    } else {
        var.set("url_path", req.url);
    }

    hash_data(var.get("url_path"));
    if (req.http.host) {
        hash_data(req.http.host);
    } else {
        hash_data(server.ip);
    }

    # if Vivoh "by" cookie is present - enforce presence for cache access (XXX ensure not spoofable in URL path)
    if(cookie.isset("by")) {
       hash_data("vivoh_auth_token");
    }
    return (lookup);
}

sub vcl_synth {
    if (req.method == "OPTIONS") {
        set resp.http.Access-Control-Allow-Headers = "Content-Type,Content-Length,Authorization,Accept,X-Requested-With";
        set resp.http.Access-Control-Allow-Methods = "GET,HEAD,OPTIONS";
        set resp.http.Access-Control-Allow-Local-Network = "true";
        set resp.http.Allow-Credentials = "true"; # XXX huh?
        set resp.http.ETag = "123456"; # XXX huh?
        if (req.http.origin) {
           set resp.http.Access-Control-Allow-Origin = req.http.origin;
        } else {
           set resp.http.Access-Control-Allow-Origin = "*";
        }
        return(deliver);
    }
}