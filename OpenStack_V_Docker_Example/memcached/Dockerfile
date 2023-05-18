FROM openstack-base:latest

LABEL maintainer="cyberpeace" name="memcached"

ENV SERVICE_NAME "memcached"

RUN usermod --append --home /run/memcache --groups cpcloud memcached \
    && mkdir -p /run/memcache \
    && chown -R 42457:42457 /run/memcache

COPY start.sh /usr/local/bin/start.sh

RUN dnf -y install memcached \
    && chmod 755 /usr/local/bin/start.sh \
    && dnf clean all && rm -rf /var/cache/dnf

COPY memcached_sudoers /etc/sudoers.d/memcached_sudoers

RUN chmod 750 /etc/sudoers.d \
    && chmod 440 /etc/sudoers.d/memcached_sudoers

USER memcached

ENTRYPOINT ["dumb-init", "--"]
CMD ["start.sh"]