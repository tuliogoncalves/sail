FROM sail:php74 as php74

ARG  ACCEPT_EULA=Y
ARG  DEBIAN_FRONTEND=noninteractive

RUN apt-get update -qq


# Add or Remove packages/files
# ...


# Remove useless packages/files
RUN pear clear-cache && \
    apt-get purge -qq --autoremove -y && \
    # Clean
    apt-get autoremove -qq -y && \
    apt-get autoclean -qq && \
    apt-get clean -qq && \
    # Empty some directories from all files and hidden files
    rm -rf /build /tmp/* && \
    find /root /var/lib/apt/lists /usr/share/man /usr/share/doc /var/cache /var/log -type f -delete
