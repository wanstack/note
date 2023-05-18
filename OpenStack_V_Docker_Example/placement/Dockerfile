FROM openstack-base:latest

LABEL maintainer="cyberpeace" name="placement"

ENV SERVICE_NAME "placement"

RUN usermod --append --home /var/lib/placement --groups cpcloud placement \
    && mkdir -p /var/lib/placement \
    && chown -R 42482:42482 /var/lib/placement

RUN dnf -y install openstack-placement-api MariaDB-client httpd \
    && dnf clean all && rm -rf /var/cache/dnf


COPY openstack-placement /etc/logrotate.d/
COPY start.sh /usr/local/bin/start.sh
COPY 00-placement-api.conf /etc/httpd/conf.d/
COPY placement.conf /etc/placement/placement.conf
COPY httpd.conf /etc/httpd/conf/httpd.conf
COPY placement_sudoers /etc/sudoers.d/

RUN chmod 755 /usr/local/bin/start.sh \
    && chmod 750 /etc/sudoers.d \
    && chmod 440 /etc/sudoers.d/placement_sudoers



ENTRYPOINT ["dumb-init", "--"]
CMD ["start.sh"]
