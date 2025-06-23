${{ content_synopsis }} This image will run qbittorrent rootless and distroless, for maximum security. Enjoy your adventures on the high sea as safe as it can be.

${{ github:> [!IMPORTANT] }}
${{ github:> }}* This image runs as 1000:1000 by default, most other images run everything as root
${{ github:> }}* This image has no shell since it is distroless, most other images run on a distro like Debian or Alpine with full shell access (security)
${{ github:> }}* This image does not ship with any critical or high rated CVE and is automatically maintained via CI/CD, most other images mostly have no CVE scanning or code quality tools in place
${{ github:> }}* This image is created via a secure, pinned CI/CD process and immune to upstream attacks, most other images have upstream dependencies that can be exploited
${{ github:> }}* This image works as read-only, most other images need to write files to the image filesystem
${{ github:> }}* This image is a lot smaller than most other images

If you value security, simplicity and the ability to interact with the maintainer and developer of an image. Using my images is a great start in that direction.

${{ content_comparison }}

${{ title_volumes }}
* **${{ json_root }}/etc** - Directory of your qBittorrent.conf and other files
* **${{ json_root }}/var** - Directory of your SQlite database for qBittorrent

${{ content_compose }}

${{ content_defaults }}
| `login` | admin // qbittorrent | login using compose example |

${{ content_environment }}

${{ content_source }}

${{ content_parent }}

${{ content_built }}

${{ content_tips }}

${{ title_caution }}
${{ github:> [!CAUTION] }}
${{ github:> }}* If you use the compose example as a base for your individual configuration, please make sure to change the default web ui login account password or provide your own qBittorrent.conf