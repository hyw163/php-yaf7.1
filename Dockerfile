FROM php:7.1.3-fpm

RUN apt-get clean -y
# Install the PHP extensions we need

RUN apt-get update && \
apt-get install -y --no-install-recommends \
    curl \
    wget \
    git \
    bzip2 \
    mysql-client \
    libmemcached-dev \
    libz-dev \
    libzip-dev \
    libpq-dev \
    libjpeg-dev \
    libpng12-dev \
    libfreetype6-dev \
    libicu-dev \
    libssl-dev \
    libmemcached-dev \
    zlib1g-dev \
    libmcrypt-dev && \
    docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr --with-freetype-dir=/usr && \
    docker-php-ext-install gd pdo_mysql pgsql pdo_pgsql mysqli opcache intl bcmath zip mcrypt sockets && \
    pecl channel-update pecl.php.net && \
    pecl install yaf-3.0.8 && \
    docker-php-ext-enable bcmath zip pdo_mysql pgsql pdo_pgsql mcrypt sockets yaf

# install memcached xdebug redis
RUN pecl install memcached xdebug redis

# install xdebug
RUN pecl install xdebug-2.7.2 

# install scws
RUN wget http://www.xunsearch.com/scws/down/scws-1.2.3.tar.bz2  \
    && tar -xjf scws-1.2.3.tar.bz2  \
    && rm scws-1.2.3.tar.bz2  \
    && mv scws-1.2.3 /tmp  \
    && cd /tmp/scws-1.2.3  \
    && ./configure --prefix=/usr/local/scws  \
    && make  \
    && make install  \
    && cd /usr/local/scws/etc \
    && wget http://www.xunsearch.com/scws/down/scws-dict-chs-gbk.tar.bz2 \
    && wget http://www.xunsearch.com/scws/down/scws-dict-chs-utf8.tar.bz2 \
    && tar xvjf scws-dict-chs-gbk.tar.bz2 \
    && tar xvjf scws-dict-chs-utf8.tar.bz2 \
    && cd /tmp/scws-1.2.3/phpext \
    && phpize \
    && ./configure --with-scws=/usr/local/scws \
    && make  \
    && make install 

# install composer
RUN php -r "readfile('https://getcomposer.org/installer');" > composer-setup.php && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \
    mv composer.phar /usr/local/bin/composer

# config china mirror
RUN composer config -g repo.packagist composer https://packagist.phpcomposer.com

VOLUME /app/web
WORKDIR /app/web