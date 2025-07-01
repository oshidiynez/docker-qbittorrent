${{ content_synopsis }} This image will run qbittorrent rootless and distroless, for maximum security. Enjoy your adventures on the high sea as safe as it can be.

${{ github:> [!IMPORTANT] }}
${{ github:> }}* This image runs [rootless](https://github.com/11notes/RTFM/blob/main/linux/container/image/rootless.md) as 1000:1000
${{ github:> }}* This image has no shell since it is [distroless](https://github.com/11notes/RTFM/blob/main/linux/container/image/distroless.md)
${{ github:> }}* This image runs read-only
${{ github:> }}* This image is automatically scanned for CVEs before and after publishing
${{ github:> }}* This image is created via a secure and pinned CI/CD process
${{ github:> }}* This image verifies all external payloads
${{ github:> }}* This image is a lot smaller

If you value security, simplicity and optimizations to the extreme, then this image might be for you.

${{ content_comparison }}

${{ title_volumes }}
* **${{ json_root }}/etc** - Directory of your qBittorrent.conf and other files
* **${{ json_root }}/var** - Directory of your SQlite database for qBittorrent

${{ content_compose }}

${{ content_defaults }}
| `login` | admin // qbittorrent | login using default config |

${{ content_environment }}

${{ content_source }}

${{ content_parent }}

${{ content_built }}

${{ content_tips }}

${{ title_caution }}
${{ github:> [!CAUTION] }}
${{ github:> }}* If you use the image with the default configuration, please make sure to change the default web ui login account password or provide your own qBittorrent.conf