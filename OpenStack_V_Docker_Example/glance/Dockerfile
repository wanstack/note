FROM openstack-base:latest

LABEL maintainer="cyberpeace" name="glance"

ENV SERVICE_NAME "glance"

RUN usermod --append --home /var/lib/glance --groups cpcloud glance \
    && mkdir -p /var/lib/glance \
    && chown -R 42415:42415 /var/lib/glance

RUN dnf -y install openstack-glance qemu-img nfs-utils MariaDB-client \
    && dnf clean all && rm -rf /var/cache/dnf \
    && rm -rf /etc/logrotate.d/* \
    && touch /opt/create.log \
    && chmod -R 777 /opt/create.log

COPY openstack-glance /etc/logrotate.d/
COPY glance_sudoers /etc/sudoers.d/glance_sudoers
COPY start.sh /usr/local/bin/start.sh
COPY create.sh /usr/local/bin/create.sh
COPY glance-api.conf /etc/glance/glance-api.conf

RUN chmod 750 /etc/sudoers.d \
    && chmod 440 /etc/sudoers.d/glance_sudoers \
    && chmod 755 /usr/local/bin/start.sh \
    && chmod 755 /usr/local/bin/create.sh

USER glance


ENTRYPOINT ["dumb-init", "--"]
CMD ["start.sh"]
