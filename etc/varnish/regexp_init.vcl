      new vimeo_range_regex = re.regex("^([^\?]*\.mp4)\?.*(range=\d+-\d+).*$");
      new manifest_path_regex = re.regex("(\.mpd|\.m3u8|\(format=m3u8-aapl\))$");
      new segment_path_regex = re.regex("\.(ts|mp3|mp4|webvtt|acc)$");
      new media_path_regex = re.regex("(\.mpd|\.m3u8|\(format=m3u8-aapl\)|\.ts|\.mp3|\.mp4|\.webvtt|\.acc)");
