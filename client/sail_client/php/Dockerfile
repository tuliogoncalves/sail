FROM sail:php81 as php

ARG  ACCEPT_EULA=Y
ARG  DEBIAN_FRONTEND=noninteractive

USER root

RUN apt-get update -qq


# Add or Remove packages/files
# ...


# Remove useless packages/files (when, sqlserver Dockerfile)
#RUN pear clear-cache

RUN apt-get purge -qq --autoremove -y && \
    # Clean
    apt-get autoremove -qq -y && \
    apt-get autoclean -qq && \
    apt-get clean -qq

# Empty some directories from all files and hidden files
RUN rm -rf /build /tmp/* && \
    find /root /var/lib/apt/lists /usr/share/man /usr/share/doc /var/cache /var/log -type f -delete

# (when, php-fpm Dockerfile)
#USER sail
