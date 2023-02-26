# docker-tordash
Dashboard of a bunch of things

### What does the image contain?

Dashboard web page (`http://your-ip/`) shows:
- Torrent search bar, with direct "Download" button in search results.
- The Transmission web interface
- Web view of the downloads directory (hosted by [Apache](https://httpd.apache.org/), styled by [Apaxy](https://oupala.github.io/apaxy/)).

### What does it look like?

##### Search for torrents
![Search for torrents](https://raw.githubusercontent.com/viranch/docker-tordash/main/screenshots/ss1.png)
##### Select from search results
![Select from search results](https://raw.githubusercontent.com/viranch/docker-tordash/main/screenshots/ss2.png)
##### Torrent downloads
![Torrent downloads](https://raw.githubusercontent.com/viranch/docker-tordash/main/screenshots/ss3.png)

### How to use?

- Install [docker](https://docs.docker.com/installation/#installation).

- Run [transmission](https://github.com/viranch/docker-transmission) and [jackett](https://github.com/viranch/docker-jackett):
```
docker run -d --name transmission -d /path/to/transmission:/data [...] ghcr.io/viranch/transmission
docker run -d --name jackett -d /path/to/jackett:/config --net container:transmission [...] ghcr.io/viranch/jackett
```

- Get Jackett API key from its web interface for supplying as env var below or use `-d /path/to/jackett:/data/jackett:ro` to let it grab the API key automagically.

- Run dashboard container (needs to share network with transmission & jackett containers):
```
docker run -d --name tordash -v /path/to/transmission/downloads:/data:ro -p 80:80 -e JACKETT_API_KEY=secretkey --net container:transmission ghcr.io/viranch/tordash
```

- [OPTIONAL] To protect your container, you can also set a username & password for basic authentication, using the `AUTH_USER` & `AUTH_PASS` environment variables:
```
docker run [...] -e AUTH_USER=bob -e AUTH_PASS=myprecious [...] ghcr.io/viranch/tordash
```

- Navigate to `http://your-ip/`. You can change the port with the `-p` switch, eg: `-p 8000:80`.

- See a sample docker-compose setup at [viranch/docker-tv](https://github.com/viranch/docker-tv)
