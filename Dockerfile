# 基于官方 PHP 7.4.33 Alpine 镜像，应用 PHP2Shell 最小缓解补丁并重新编译 PHP。
# 只包含 PHP 核心和 FPM，扩展（mcrypt/imap/pdo_pgsql 等）需要单独阶段处理。

ARG BASE=php:7.4.33-fpm-alpine3.16
FROM ${BASE}

ARG MAKE_JOBS

COPY patches/7.4-CVE-2026-109618-109619.patch /usr/src/cve.patch

RUN set -eux; \
    sed -i 's|dl-cdn.alpinelinux.org|archive.alpinelinux.org|g' /etc/apk/repositories; \
    apk add --no-cache libedit; \
    apk add --no-cache --virtual .fix-build-deps \
        $PHPIZE_DEPS patch \
        curl-dev libxml2-dev openssl-dev sqlite-dev libedit-dev oniguruma-dev \
        libsodium-dev argon2-dev; \
    docker-php-source extract; \
    cd /usr/src/php; \
    patch -p1 --dry-run < /usr/src/cve.patch; \
    patch -p1 < /usr/src/cve.patch; \
    grep -q zend_mm_safe_error_ex Zend/zend_alloc.c; \
    grep -q max_multipart_body_parts main/main.c; \
    export CFLAGS="$PHP_CFLAGS" CPPFLAGS="$PHP_CPPFLAGS" LDFLAGS="$PHP_LDFLAGS"; \
    ./configure \
        --build="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE 2>/dev/null || echo x86_64-alpine-linux-musl)" \
        --with-config-file-path="$PHP_INI_DIR" \
        --with-config-file-scan-dir="$PHP_INI_DIR/conf.d" \
        --enable-option-checking=fatal \
        --with-mhash --with-pic --enable-ftp --enable-mbstring --enable-mysqlnd \
        --with-password-argon2 --with-sodium=shared \
        --with-pdo-sqlite=/usr --with-sqlite3=/usr \
        --with-curl --with-libedit --with-openssl --with-zlib \
        --disable-cgi --enable-fpm --with-fpm-user=www-data --with-fpm-group=www-data; \
    make -j"${MAKE_JOBS:-$(nproc)}"; \
    make install; \
    cd /; \
    docker-php-source delete; \
    apk del --no-network .fix-build-deps; \
    php -v; \
    php -r 'echo "max_multipart_body_parts=", ini_get("max_multipart_body_parts"), PHP_EOL;'
