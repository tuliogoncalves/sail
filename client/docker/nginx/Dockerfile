FROM nginx:stable-alpine
LABEL stage=nginx-production

ARG user

COPY ./docker/nginx/default.conf /etc/nginx/conf.d/default.conf
COPY ./docker/nginx/nginx.conf /etc/nginx/nginx.conf

COPY ./public /var/www/public

WORKDIR /var/www
