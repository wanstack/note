FROM openstack-base:latest

LABEL maintainer="cyberpeace" name="keystone"

ENV SERVICE_NAME "keystone"

RUN usermod --append --home /var/lib/keystone --groups cpcloud keystone \
    && mkdir -p /var/lib/keystone \
    && chown -R 42425:42425 /var/lib/keystone

RUN dnf -y install  openstack-keystone httpd python3-mod_wsgi MariaDB-client\
    && dnf clean all && rm -rf /var/cache/dnf

COPY keystone_sudoers /etc/sudoers.d/keystone_sudoers
COPY wsgi-keystone.conf /usr/share/keystone/wsgi-keystone.conf
COPY keystone.conf /etc/keystone/keystone.conf
COPY httpd.conf /etc/httpd/conf/httpd.conf
COPY openstack-keystone /etc/logrotate.d/
COPY healthcheck.sh /usr/local/bin/healthcheck.sh
COPY start.sh /usr/local/bin/start.sh
COPY create.sh /usr/local/bin/create.sh
HEALTHCHECK --interval=60s --timeout=5s --retries=3 CMD /bin/bash /usr/local/bin/healthcheck.sh

RUN chmod 750 /etc/sudoers.d \
    && chmod 440 /etc/sudoers.d/keystone_sudoers \
    && chmod 755 /usr/local/bin/start.sh \
    && chmod 755 /usr/local/bin/create.sh


ENTRYPOINT ["dumb-init", "--"]
CMD ["start.sh"]

