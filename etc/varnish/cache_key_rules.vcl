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
