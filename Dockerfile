FROM alipeng/php5.6-node10-ffmpeg:latest

LABEL maintainer Alipeng <lipeng.yang@mobvista.com>

ENV TZ=Asia/Shanghai \
    PHP_USER_ID=82 \
    PATH=/root/.composer/vendor/bin:$PATH \
    TERM=linux \
    COMPOSER_ALLOW_SUPERUSER=1

RUN set -xe \
    && apk add --no-cache \
        curl \
        wget \
        git \
        bash \
        vim \
        openssh-client \
        redis \
        tree \
        tzdata\
    && curl -sS https://getcomposer.org/installer | php -- \
            --filename=composer \
            --install-dir=/usr/local/bin \
    &&  composer clear-cache \
    && cp -rf /usr/share/zoneinfo/$TZ /etc/localtime \
    && npm install -g pm2 \
    && wget https://psysh.org/psysh \
    && chmod +x psysh \
    && mv psysh /usr/local/bin \
    && apk -v --update add \
       python \
       py-pip \
       groff \
       less \
       mailcap \
    && pip install --upgrade awscli s3cmd python-magic \
    && apk -v --purge del py-pip \
    && rm /var/cache/apk/*

WORKDIR /var/www

ENTRYPOINT [ "bash" ]
