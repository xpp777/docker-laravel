FROM php:7.4.33-fpm

RUN docker-php-ext-install pdo_mysql
# 安装必要的系统依赖
RUN apt-get update && apt-get install -y \
    libzip-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libmcrypt-dev \
    libmariadb-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd \
    && pecl install redis \
    && pecl install mcrypt-1.0.4 \
    && pecl install igbinary \
    && docker-php-ext-install mysqli pdo pdo_mysql \
    && docker-php-ext-enable redis mcrypt igbinary \
    && docker-php-ext-install opcache \
    && docker-php-ext-install zip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


RUN apt-get update && apt-get install -y nano cron

RUN apt-get update && apt-get install supervisor -y

RUN apt-get update && apt-get install -y nginx  && \
    rm -rf /var/lib/apt/lists/*


COPY . /var/www/html
WORKDIR /var/www/html

RUN rm /etc/nginx/sites-enabled/default

COPY ./deploy/deploy.conf /etc/nginx/conf.d/default.conf

RUN mv /usr/local/etc/php-fpm.d/www.conf /usr/local/etc/php-fpm.d/www.conf.backup

COPY ./deploy/www.conf /usr/local/etc/php-fpm.d/www.conf
COPY ./deploy/cronjob /etc/cron.d/cronjob
COPY ./deploy/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN usermod -a -G www-data root
RUN chgrp -R www-data storage

RUN chown -R www-data:www-data ./storage
RUN chmod -R 0777 ./storage
RUN chmod 0644 /etc/cron.d/cronjob
COPY ./deploy/run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

CMD ["/usr/local/bin/run.sh"]

EXPOSE 80