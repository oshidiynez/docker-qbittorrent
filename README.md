![banner](https://github.com/11notes/defaults/blob/main/static/img/banner.png?raw=true)

# QBITTORRENT
![size](https://img.shields.io/docker/image-size/11notes/qbittorrent/5.1.2?color=0eb305)![5px](https://github.com/11notes/defaults/blob/main/static/img/transparent5x2px.png?raw=true)![version](https://img.shields.io/docker/v/11notes/qbittorrent/5.1.2?color=eb7a09)![5px](https://github.com/11notes/defaults/blob/main/static/img/transparent5x2px.png?raw=true)![pulls](https://img.shields.io/docker/pulls/11notes/qbittorrent?color=2b75d6)![5px](https://github.com/11notes/defaults/blob/main/static/img/transparent5x2px.png?raw=true)[<img src="https://img.shields.io/github/issues/11notes/docker-QBITTORRENT?color=7842f5">](https://github.com/11notes/docker-QBITTORRENT/issues)![5px](https://github.com/11notes/defaults/blob/main/static/img/transparent5x2px.png?raw=true)![swiss_made](https://img.shields.io/badge/Swiss_Made-FFFFFF?labelColor=FF0000&logo=data:image/svg%2bxml;base64,PHN2ZyB2ZXJzaW9uPSIxIiB3aWR0aD0iNTEyIiBoZWlnaHQ9IjUxMiIgdmlld0JveD0iMCAwIDMyIDMyIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPgogIDxyZWN0IHdpZHRoPSIzMiIgaGVpZ2h0PSIzMiIgZmlsbD0idHJhbnNwYXJlbnQiLz4KICA8cGF0aCBkPSJtMTMgNmg2djdoN3Y2aC03djdoLTZ2LTdoLTd2LTZoN3oiIGZpbGw9IiNmZmYiLz4KPC9zdmc+)

Run qbittorrent rootless and distroless.

# INTRODUCTION 📢

qBittorrent is a bittorrent client programmed in C++ / Qt that uses libtorrent (sometimes called libtorrent-rasterbar) by Arvid Norberg.

# SYNOPSIS 📖
**What can I do with this?** This image will run qbittorrent [rootless](https://github.com/11notes/RTFM/blob/main/linux/container/image/rootless.md) and [distroless](https://github.com/11notes/RTFM/blob/main/linux/container/image/distroless.md), for maximum security. Enjoy your adventures on the high sea as safe[^1] as it can be.

# UNIQUE VALUE PROPOSITION 💶
**Why should I run this image and not the other image(s) that already exist?** Good question! Because ...

> [!IMPORTANT]
>* ... this image runs [rootless](https://github.com/11notes/RTFM/blob/main/linux/container/image/rootless.md) as 1000:1000
>* ... this image has no shell since it is [distroless](https://github.com/11notes/RTFM/blob/main/linux/container/image/distroless.md)
>* ... this image is auto updated to the latest version via CI/CD
>* ... this image has a health check
>* ... this image runs read-only
>* ... this image is automatically scanned for CVEs before and after publishing
>* ... this image is created via a secure and pinned CI/CD process
>* ... this image verifies all external payloads
>* ... this image is very small

If you value security, simplicity and optimizations to the extreme, then this image might be for you.

# COMPARISON 🏁
Below you find a comparison between this image and the most used or original one.

| **image** | 11notes/qbittorrent:5.1.2 | linuxserver/qbittorrent:5.1.2 |
| ---: | :---: | :---: |
| **image size on disk** | 21.8MB | 198MB |
| **process UID/GID** | 1000/1000 | 0/0 |
| **distroless?** | ✅ | ❌ |
| **rootless?** | ✅ | ❌ |


# VOLUMES 📁
* **/qbittorrent/etc** - Directory of your qBittorrent.conf and other files
* **/qbittorrent/var** - Directory of your SQlite database for qBittorrent

# COMPOSE ✂️
```yaml
name: "arr"
services:
  qbittorrent:
    image: "11notes/qbittorrent:5.1.2"
    read_only: true
    environment:
      TZ: "Europe/Zurich"
    volumes:
      - "qbittorrent.etc:/qbittorrent/etc"
      - "qbittorrent.var:/qbittorrent/var"
    ports:
      - "3000:3000/tcp"
      - "6881:6881/tcp"
      - "6881:6881/udp"
    networks:
      frontend:
    restart: "always"

volumes:
  qbittorrent.etc:
  qbittorrent.var:

networks:
  frontend:
```

# DEFAULT SETTINGS 🗃️
| Parameter | Value | Description |
| --- | --- | --- |
| `user` | docker | user name |
| `uid` | 1000 | [user identifier](https://en.wikipedia.org/wiki/User_identifier) |
| `gid` | 1000 | [group identifier](https://en.wikipedia.org/wiki/Group_identifier) |
| `home` | /qbittorrent | home directory of user docker |
| `login` | admin // qbittorrent | login using default config |

# ENVIRONMENT 📝
| Parameter | Value | Default |
| --- | --- | --- |
| `TZ` | [Time Zone](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) | |
| `DEBUG` | Will activate debug option for container image and app (if available) | |

# MAIN TAGS 🏷️
These are the main tags for the image. There is also a tag for each commit and its shorthand sha256 value.

* [5.1.2](https://hub.docker.com/r/11notes/qbittorrent/tags?name=5.1.2)

### There is no latest tag, what am I supposed to do about updates?
It is of my opinion that the ```:latest``` tag is dangerous. Many times, I’ve introduced **breaking** changes to my images. This would have messed up everything for some people. If you don’t want to change the tag to the latest [semver](https://semver.org/), simply use the short versions of [semver](https://semver.org/). Instead of using ```:5.1.2``` you can use ```:5``` or ```:5.1```. Since on each new version these tags are updated to the latest version of the software, using them is identical to using ```:latest``` but at least fixed to a major or minor version.

If you still insist on having the bleeding edge release of this app, simply use the ```:rolling``` tag, but be warned! You will get the latest version of the app instantly, regardless of breaking changes or security issues or what so ever. You do this at your own risk!

# REGISTRIES ☁️
```
docker pull 11notes/qbittorrent:5.1.2
docker pull ghcr.io/11notes/qbittorrent:5.1.2
docker pull quay.io/11notes/qbittorrent:5.1.2
```

# SOURCE 💾
* [11notes/qbittorrent](https://github.com/11notes/docker-QBITTORRENT)

# PARENT IMAGE 🏛️
> [!IMPORTANT]
>This image is not based on another image but uses [scratch](https://hub.docker.com/_/scratch) as the starting layer.
>The image consists of the following distroless layers that were added:
>* [11notes/distroless](https://github.com/11notes/docker-distroless/blob/master/arch.dockerfile) - contains users, timezones and Root CA certificates

# BUILT WITH 🧰
* [qbittorrent/qBittorrent](https://github.com/qbittorrent/qBittorrent)

# GENERAL TIPS 📌
> [!TIP]
>* Use a reverse proxy like Traefik, Nginx, HAproxy to terminate TLS and to protect your endpoints
>* Use Let’s Encrypt DNS-01 challenge to obtain valid SSL certificates for your services

# CAUTION ⚠️
> [!CAUTION]
>* If you use the image with the default configuration, please make sure to change the default web ui login account password or provide your own qBittorrent.conf

[^1]: Check the [compose.vpn.yml](https://github.com/11notes/docker-qbittorrent/blob/master/compose.vpn.yml) example on how to use this image with a VPN provider like gluetun.

# ElevenNotes™️
This image is provided to you at your own risk. Always make backups before updating an image to a different version. Check the [releases](https://github.com/11notes/docker-qbittorrent/releases) for breaking changes. If you have any problems with using this image simply raise an [issue](https://github.com/11notes/docker-qbittorrent/issues), thanks. If you have a question or inputs please create a new [discussion](https://github.com/11notes/docker-qbittorrent/discussions) instead of an issue. You can find all my other repositories on [github](https://github.com/11notes?tab=repositories).

*created 27.07.2025, 12:53:32 (CET)*