# ╔═════════════════════════════════════════════════════╗
# ║                       SETUP                         ║
# ╚═════════════════════════════════════════════════════╝
  # GLOBAL
  ARG APP_UID=1000 \
      APP_GID=1000 \
      BUILD_ROOT=/ \
      BUILD_BIN=/qbittorrent \
      APP_LIBTORRENT_VERSION=2.0.11

  # :: FOREIGN IMAGES
  FROM 11notes/distroless AS distroless
  FROM 11notes/util AS util

# ╔═════════════════════════════════════════════════════╗
# ║                       BUILD                         ║
# ╚═════════════════════════════════════════════════════╝
  # :: qbittorrent
  FROM alpine AS build
  COPY --from=util /usr/local/bin /usr/local/bin
  ARG APP_VERSION \
      BUILD_ROOT \
      BUILD_BIN \
      TARGETARCH \
      TARGETPLATFORM \
      TARGETVARIANT \
      URL_PREFIX="https://github.com/userdocs/qbittorrent-nox-static/releases/download/" \
      APP_LIBTORRENT_VERSION

  RUN set -ex; \
    apk --update --no-cache add \
      build-base \
      upx \
      wget;

  RUN set -ex; \
    case "${TARGETARCH}${TARGETVARIANT}" in \
      "amd64") wget ${URL_PREFIX}/release-${APP_VERSION}_v${APP_LIBTORRENT_VERSION}/x86_64-qbittorrent-nox -O ${BUILD_BIN};; \
      "arm64") wget ${URL_PREFIX}/release-${APP_VERSION}_v${APP_LIBTORRENT_VERSION}/aarch64-qbittorrent-nox -O ${BUILD_BIN};; \
      "armv7") wget ${URL_PREFIX}/release-${APP_VERSION}_v${APP_LIBTORRENT_VERSION}/armv7-qbittorrent-nox -O ${BUILD_BIN};; \
    esac;

  RUN set -ex; \
    mkdir -p /distroless/usr/local/bin; \
    eleven checkStatic ${BUILD_BIN}; \
    eleven strip ${BUILD_BIN}; \
    chmod +x ${BUILD_BIN}; \
    cp ${BUILD_BIN} /distroless/usr/local/bin;

  # :: file system
  FROM alpine AS file-system
  COPY --from=util /usr/local/bin /usr/local/bin
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
    COPY --from=distroless-unrar / /
    COPY --from=build /distroless/ /
    COPY --from=file-system --chown=${APP_UID}:${APP_GID} /distroless/ /
    COPY --chown=${APP_UID}:${APP_GID} ./rootfs/ /

# :: PERSISTENT DATA
  VOLUME ["${APP_ROOT}/etc", "${APP_ROOT}/var"]

# :: EXECUTE
  USER ${APP_UID}:${APP_GID}
  ENTRYPOINT ["/usr/local/bin/qbittorrent"]
  CMD ["--profile=/opt"]