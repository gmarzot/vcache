       if (manifest_path_regex.match(bereq.url)) {
          set beresp.ttl = 1s;
          return(deliver);
       } else if (segment_path_regex.match(bereq.url)) {
          set beresp.ttl = 300s;
          return(deliver);
       }
