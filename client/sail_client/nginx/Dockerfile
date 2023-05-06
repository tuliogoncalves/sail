FROM nginx:stable-alpine
LABEL stage=nginx-production

ARG user

COPY ./sail_client/nginx/default.conf /etc/nginx/conf.d/default.conf
COPY ./sail_client/nginx/nginx.conf /etc/nginx/nginx.conf

COPY ./public /var/www/public

WORKDIR /var/www
