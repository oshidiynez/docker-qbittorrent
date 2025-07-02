# ╔═════════════════════════════════════════════════════╗
# ║                       SETUP                         ║
# ╚═════════════════════════════════════════════════════╝
  # GLOBAL
  ARG APP_UID=1000 \
      APP_GID=1000 \
      BUILD_ROOT=/ \
      BUILD_BIN=qbittorrent \
      APP_LIBTORRENT_VERSION=2.0.11

  # :: FOREIGN IMAGES
  FROM 11notes/distroless AS distroless
  FROM 11notes/distroless:curl AS distroless-curl
  FROM 11notes/util:bin AS util

# ╔═════════════════════════════════════════════════════╗
# ║                       BUILD                         ║
# ╚═════════════════════════════════════════════════════╝
  # :: qbittorrent
  FROM alpine AS build
  COPY --from=util / /
  ARG APP_VERSION \
      BUILD_ROOT \
      BUILD_BIN \
      TARGETARCH \
      TARGETPLATFORM \
      TARGETVARIANT \
      APP_LIBTORRENT_VERSION

  ENV BUILD_BIN=qbittorrent

  RUN set -ex; \
    apk --update --no-cache add \
      jq \
      curl \
      wget;

  RUN set -ex; \
    case "${TARGETARCH}${TARGETVARIANT}" in \
      "amd64") export QBITTORRENT_NAME=x86_64-qbittorrent-nox;; \
      "arm64") export QBITTORRENT_NAME=aarch64-qbittorrent-nox;; \
      "armv7") export QBITTORRENT_NAME=armv7-qbittorrent-nox;; \
    esac; \
    GITHUB_SHA256=$(curl -s -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" https://api.github.com/repos/userdocs/qbittorrent-nox-static/releases | jq --raw-output '.[] | select(.tag_name == "release-'${APP_VERSION}_v${APP_LIBTORRENT_VERSION}'") | .assets[] | select(.name == "'${QBITTORRENT_NAME}'") | .digest' | sed 's/sha256://'); \
    GITHUB_BIN=$(curl -s -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" https://api.github.com/repos/userdocs/qbittorrent-nox-static/releases | jq --raw-output '.[] | select(.tag_name == "release-'${APP_VERSION}_v${APP_LIBTORRENT_VERSION}'") | .assets[] | select(.name == "'${QBITTORRENT_NAME}'") | .browser_download_url'); \
    wget ${GITHUB_BIN} -O ${BUILD_BIN}; \
    echo "${GITHUB_SHA256} ${BUILD_BIN}" | sha256sum -c || exit 1

  RUN set -ex; \
    mkdir -p /distroless/usr/local/bin; \
    chmod +x ${BUILD_BIN}; \
    eleven checkStatic ${BUILD_BIN}; \
    eleven strip ${BUILD_BIN}; \
    cp ${BUILD_BIN} /distroless/usr/local/bin;

  # :: file system
  FROM alpine AS file-system
  COPY --from=util / /
  ARG APP_ROOT
  USER root

  RUN set -ex; \
    eleven mkdir /distroless${APP_ROOT}/{etc,var,cache}; \
    mkdir -p /distroless/opt/qBittorrent/logs; \
    eleven mkdir ${APP_ROOT}/{etc,var,cache}; \
    ln -sf ${APP_ROOT}/etc /distroless/opt/qBittorrent/config; \
    ln -sf ${APP_ROOT}/var /distroless/opt/qBittorrent/data; \
    ln -sf ${APP_ROOT}/cache /distroless/opt/qBittorrent/cache; \
    ln -sf /dev/stdout /distroless/opt/qBittorrent/logs/qbittorrent.log;


# ╔═════════════════════════════════════════════════════╗
# ║                       IMAGE                         ║
# ╚═════════════════════════════════════════════════════╝
  # :: HEADER
  FROM scratch

  # :: default arguments
    ARG TARGETPLATFORM \
        TARGETOS \
        TARGETARCH \
        TARGETVARIANT \
        APP_IMAGE \
        APP_NAME \
        APP_VERSION \
        APP_ROOT \
        APP_UID \
        APP_GID \
        APP_NO_CACHE

  # :: default environment
    ENV APP_IMAGE=${APP_IMAGE} \
        APP_NAME=${APP_NAME} \
        APP_VERSION=${APP_VERSION} \
        APP_ROOT=${APP_ROOT}

  # :: multi-stage
    COPY --from=distroless / /
    COPY --from=distroless-curl / /
    COPY --from=build /distroless/ /
    COPY --from=file-system --chown=${APP_UID}:${APP_GID} /distroless/ /
    COPY --chown=${APP_UID}:${APP_GID} ./rootfs/ /

# :: PERSISTENT DATA
  VOLUME ["${APP_ROOT}/etc", "${APP_ROOT}/var"]

# :: MONITORING
  HEALTHCHECK --interval=5s --timeout=2s --start-period=5s \
    CMD ["/usr/local/bin/curl", "-kILs", "--fail", "-o", "/dev/null", "http://localhost:3000/api/v2/app/version"]

# :: EXECUTE
  USER ${APP_UID}:${APP_GID}
  ENTRYPOINT ["/usr/local/bin/qbittorrent"]
  CMD ["--profile=/opt"]