# ╔═════════════════════════════════════════════════════╗
# ║                       SETUP                         ║
# ╚═════════════════════════════════════════════════════╝
# GLOBAL
  ARG APP_UID=1000 \
      APP_GID=1000 \
      BUILD_BIN=qbittorrent \
      APP_LIBTORRENT_VERSION=2.0.11

# :: FOREIGN IMAGES
  FROM 11notes/distroless AS distroless
  FROM 11notes/distroless:localhealth AS distroless-localhealth
  FROM 11notes/util:bin AS util-bin
  FROM 11notes/util AS util

# ╔═════════════════════════════════════════════════════╗
# ║                       BUILD                         ║
# ╚═════════════════════════════════════════════════════╝
# :: QBITTORRENT
  FROM alpine AS build
  COPY --from=util-bin / /
  ARG APP_VERSION \
      BUILD_BIN \
      TARGETARCH \
      TARGETPLATFORM \
      TARGETVARIANT \
      APP_LIBTORRENT_VERSION

  RUN set -ex; \
    case "${TARGETARCH}${TARGETVARIANT}" in \
      "amd64") eleven github asset userdocs/qbittorrent-nox-static release-${APP_VERSION}_v${APP_LIBTORRENT_VERSION} x86_64-qbittorrent-nox; mv x86_64-qbittorrent-nox ${BUILD_BIN};; \
      "arm64") eleven github asset userdocs/qbittorrent-nox-static release-${APP_VERSION}_v${APP_LIBTORRENT_VERSION} aarch64-qbittorrent-nox; mv aarch64-qbittorrent-nox ${BUILD_BIN};; \
      "armv7") eleven github asset userdocs/qbittorrent-nox-static release-${APP_VERSION}_v${APP_LIBTORRENT_VERSION} armv7-qbittorrent-nox; mv armv7-qbittorrent-nox ${BUILD_BIN};; \
    esac;

  RUN set -ex; \
    eleven distroless ${BUILD_BIN};

# :: FILE SYSTEM
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
    COPY --from=distroless-localhealth / /
    COPY --from=build /distroless/ /
    COPY --from=file-system --chown=${APP_UID}:${APP_GID} /distroless/ /
    COPY --chown=${APP_UID}:${APP_GID} ./rootfs/ /

# :: PERSISTENT DATA
  VOLUME ["${APP_ROOT}/etc", "${APP_ROOT}/var"]

# :: MONITORING
  HEALTHCHECK --interval=5s --timeout=2s --start-period=5s \
    CMD ["/usr/local/bin/localhealth", "http://127.0.0.1:8080/api/v2/app/version", "-I"]

# :: EXECUTE
  USER ${APP_UID}:${APP_GID}
  ENTRYPOINT ["/usr/local/bin/qbittorrent"]
  CMD ["--profile=/opt"]