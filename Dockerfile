FROM alipeng/php5.6-node10-ffmpeg

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
        zsh \
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
    &&  sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"  || true\
    && git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions \
    && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting \
    && sed -i 's/plugins=(/plugins=(zsh-autosuggestions zsh-syntax-highlighting/' ~/.zshrc

WORKDIR /var/www

ENTRYPOINT [ "/bin/zsh" ]

