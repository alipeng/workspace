FROM debian:jessie

LABEL maintainer Alipeng <lipeng.yang@mobvista.com>

RUN sed -i 's/deb.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        apt-transport-https \
        ca-certificates \
        wget \
        software-properties-common &&\
        wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg && \
	    sh -c 'echo "deb https://mirror.xtom.com.hk/sury/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list' && \
    apt-get update && \
	apt-get install -y --no-install-recommends \
        git \
        curl \
        vim \
        make \
        locales \
        openssh-client \
        php5.6-mysql \
        php5.6-curl \
        php5.6-gd \
        php5.6-mbstring \
        php5.6-mcrypt \
        php5.6-xml \
        php5.6-xmlrpc \
        php5.6-zip \
        php5.6-opcache \
        php5.6-pgsql \
        php5.6-pdo-mysql \
        php5.6-bcmath \
        php5.6-cli \
        php-pear \
        php5.6-dev && \
    apt-get clean && \
    pecl channel-update pecl.php.net && \
    printf "\n" | pecl install -o -f redis && \
    printf "\n" | pecl install -o -f xdebug-2.5.0 && \
    echo "extension=redis.so" >> /etc/php/5.6/mods-available/redis.ini && \
    echo "zend_extension=xdebug.so" >> /etc/php/5.6/mods-available/xdebug.ini && \
    phpenmod redis xdebug &&\
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 

# gpg keys listed at https://github.com/nodejs/node#release-team
RUN set -ex \
  && for key in \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    FD3A5288F042B6850C66B31F09FE44734EB7990E \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
    B9AE9905FFD7803F25714661B63B535A4C206CA9 \
    56730D5401028683275BD23C23EFEFE93C4CFFFE \
    77984A986EBC2AA786BC0F66B01FBB92821C587A \
  ; do \
    gpg --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "$key" || \
    gpg --keyserver hkp://ipv4.pool.sks-keyservers.net --recv-keys "$key" || \
    gpg --keyserver hkp://pgp.mit.edu:80 --recv-keys "$key" ; \
  done

ENV NODE_VERSION 8.10.0

RUN ARCH= && dpkgArch="$(dpkg --print-architecture)" \
  && case "${dpkgArch##*-}" in \
    amd64) ARCH='x64';; \
    ppc64el) ARCH='ppc64le';; \
    *) echo "unsupported architecture"; exit 1 ;; \
  esac \
  && curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-$ARCH.tar.xz" \
  && curl -SLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
  && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
  && grep " node-v$NODE_VERSION-linux-$ARCH.tar.xz\$" SHASUMS256.txt | sha256sum -c - \
  && tar -xJf "node-v$NODE_VERSION-linux-$ARCH.tar.xz" -C /usr/local --strip-components=1 --no-same-owner \
  && rm "node-v$NODE_VERSION-linux-$ARCH.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt \
  && ln -s /usr/local/bin/node /usr/local/bin/nodejs

# Environment settings
ENV PHP_USER_ID=82 \
    PATH=/root/.composer/vendor/bin:$PATH \
    TERM=linux \
    COMPOSER_ALLOW_SUPERUSER=1

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- \
        --filename=composer \
        --install-dir=/usr/local/bin && \
    composer clear-cache

# Set Timezone
ARG TZ=Asia/Shanghai
ENV TZ ${TZ}
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Change uid and gid of www-data
RUN usermod -u 82 www-data && \
    groupmod -g 82 www-data

WORKDIR /var/www

CMD ["bash"]
