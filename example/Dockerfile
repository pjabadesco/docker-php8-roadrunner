FROM pjabadesco/php8-roadrunner:latest

COPY php.ini /usr/local/etc/php/
RUN  chmod 755 /var/www/html -R
COPY --chown=www-data:www-data www/ /var/www/html/
