FROM debian:buster

RUN apt-get update -y && apt-get upgrade
RUN apt install -y curl wget gnupg2 ca-certificates lsb-release apt-transport-https git supervisor

# add php7.4 packages from other repo
RUN wget https://packages.sury.org/php/apt.gpg
RUN apt-key add apt.gpg
RUN echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php7.list
RUN apt update -y

#install php and modules
RUN apt install -y php7.4-fpm php7.4-common php7.4-cli \
                   php7.4-mysql php7.4-gmp php7.4-curl \
                   php7.4-zip php7.4-intl php7.4-mbstring \
                   php7.4-xmlrpc php7.4-gd php7.4-xml php-xdebug

#config php with .ini file (both fpm and cli)
COPY php/30-user.ini /etc/php/7.4/fpm/conf.d/30-user.ini
COPY php/20-xdebug.ini /etc/php/7.4/fpm/conf.d/20-xdebug.ini

#install nginx
RUN apt install -y nginx

# config nginx
COPY nginx/httpscertificate /etc/nginx/httpscertificate
COPY nginx/snippets/wordpress-single.conf /etc/nginx/snippets/wordpress-single.conf
COPY nginx/sites-available/default /etc/nginx/sites-available/default

# install composer
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer \
    && chmod +x /usr/local/bin/composer

# setup
COPY projects/base /var/www/base
COPY entrypoint.sh /etc/entrypoint.sh
COPY listener.php /listener.php
COPY supervisor.conf /etc/supervisor/conf.d/supervisor.conf

#bugfix: php-fpm7.4 creates a file, but has no rights to create the dir
RUN mkdir -p /run/php

EXPOSE 80
EXPOSE 443
ENTRYPOINT ["sh", "/etc/entrypoint.sh"]