# ╔═════════════════════════════════════════════════════╗
# ║                       SETUP                         ║
# ╚═════════════════════════════════════════════════════╝
# GLOBAL
  ARG APP_UID=1000 \
      APP_GID=1000 \
      QT_VERSION=6.9.2 \
      APP_OPENSSL_VERSION=3.5.3 \
      APP_BOOST_VERSION=1.89.0 \
      APP_ZLIB_VERSION=1.3.1 \
      APP_LIBTORRENT_VERSION=2.0.11

# :: FOREIGN IMAGES
  FROM 11notes/distroless AS distroless
  FROM 11notes/distroless:localhealth AS distroless-localhealth
  FROM 11notes/distroless:qt-minimal-${QT_VERSION} AS distroless-qt
  FROM 11notes/distroless:unrar AS distroless-unrar
  FROM 11notes/util:bin AS util-bin
  FROM 11notes/util AS util

# ╔═════════════════════════════════════════════════════╗
# ║                       BUILD                         ║
# ╚═════════════════════════════════════════════════════╝
# :: OPENSSL & ZLIB
  FROM alpine AS build
  COPY --from=distroless-qt / /
  COPY --from=util-bin / /

  ARG APP_VERSION \
      TARGETARCH \
      TARGETVARIANT \
      APP_OPENSSL_VERSION \
      APP_BOOST_VERSION \
      APP_ZLIB_VERSION \
      APP_LIBTORRENT_VERSION

  RUN set -ex; \
    apk --update --no-cache add \
      perl \
      g++ \
      make \
      linux-headers \
      git \
      cmake \
      build-base \
      samurai \
      python3 \
      py3-pkgconfig \
      pkgconfig;

  # BOOST
  RUN set -ex; \
    eleven github asset boostorg/boost boost-${APP_BOOST_VERSION} boost-${APP_BOOST_VERSION}-b2-nodocs.tar.gz;

  # OPENSSL
  RUN set -ex; \
    eleven github asset openssl/openssl openssl-${APP_OPENSSL_VERSION} openssl-${APP_OPENSSL_VERSION}.tar.gz;

  RUN set -ex; \
    cd /openssl-${APP_OPENSSL_VERSION}; \
    case "${TARGETARCH}${TARGETVARIANT}" in \
      "amd64"|"arm64") \
        ./Configure \
          -static \
          --openssldir=/etc/ssl; \
      ;; \
      \
      "armv7") \
        ./Configure \
          linux-generic32 \
          -static \
          --openssldir=/etc/ssl; \
      ;; \
    esac; \
    make -s -j $(nproc) 2>&1 > /dev/null; \
    make -s -j $(nproc) install_sw 2>&1 > /dev/null; \
    cp -af /openssl-${APP_OPENSSL_VERSION}/libssl.a /usr/lib; \
    cp -af /openssl-${APP_OPENSSL_VERSION}/libcrypto.a /usr/lib;

  # ZLIB
  RUN set -ex; \
    eleven github asset madler/zlib v${APP_ZLIB_VERSION} zlib-${APP_ZLIB_VERSION}.tar.gz;

  RUN set -ex; \
    cd /zlib-${APP_ZLIB_VERSION}; \
    ./configure --static; \
    make -s -j $(nproc) 2>&1 > /dev/null; \
    make -s -j $(nproc) install 2>&1 > /dev/null;

  # LIBTORRENT
  RUN set -ex; \
    eleven github asset arvidn/libtorrent v${APP_LIBTORRENT_VERSION} libtorrent-rasterbar-${APP_LIBTORRENT_VERSION}.tar.gz;  

  RUN set -ex; \
    cd /libtorrent-rasterbar-${APP_LIBTORRENT_VERSION}; \
    cmake -Wno-dev -B build -G Ninja \
      -DCMAKE_BUILD_TYPE="Release" \
      -DBOOST_INCLUDEDIR="/boost-${APP_BOOST_VERSION}/" \
      -DCMAKE_CXX_STANDARD=17 \
      -DCMAKE_INSTALL_LIBDIR="lib" \
      -DCMAKE_INSTALL_PREFIX="/usr/local" \
      -DCMAKE_EXE_LINKER_FLAGS="-static" \
      -DBUILD_SHARED_LIBS=OFF \
      -DOPENSSL_USE_STATIC_LIBS=TRUE; \
    cmake --build build; \
    cmake --install build;

  # QBITTORRENT
  RUN set -ex; \
    eleven git clone qbittorrent/qBittorrent.git release-${APP_VERSION};

  RUN set -ex; \
    cd /qBittorrent; \
    QT_BASE_DIR="/opt/qt" \
    LD_LIBRARY_PATH="/opt/qt/lib" \
      cmake -Wno-dev -B build -G Ninja \
        -DQT6=ON \
        -DGUI=OFF \
        -DSTACKTRACE=OFF \
        -DBUILD_SHARED_LIBS=OFF \
        -DCMAKE_PREFIX_PATH="/opt/qt" \
        -DCMAKE_BUILD_TYPE="Release" \
        -DBOOST_INCLUDEDIR="/boost-${APP_BOOST_VERSION}/" \
        -DCMAKE_CXX_STANDARD="17" \
        -DCMAKE_EXE_LINKER_FLAGS="-static"; \
    cmake --build build; \
    cmake --install build;

  RUN set -ex; \
    mv /usr/local/bin/qbittorrent-nox /usr/local/bin/qbittorrent; \
    eleven distroless /usr/local/bin/qbittorrent;

# :: FILE SYSTEM
  FROM alpine AS file-system
  COPY --from=util / /
  ARG APP_ROOT

  RUN set -ex; \
    eleven mkdir /distroless${APP_ROOT}/{etc,var,cache}; \
    mkdir -p /distroless/opt/qBittorrent/logs; \
    eleven mkdir ${APP_ROOT}/{etc,var,cache}; \
    ln -sf ${APP_ROOT}/etc /distroless/opt/qBittorrent/config; \
    ln -sf ${APP_ROOT}/var /distroless/opt/qBittorrent/data; \
    ln -sf ${APP_ROOT}/cache /distroless/opt/qBittorrent/cache; \
    ln -sf /dev/stdout /distroless/opt/qBittorrent/logs/qbittorrent.log; \
    chmod -R 0755 /distroless/opt/qBittorrent;


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
    COPY --from=distroless-unrar / /
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