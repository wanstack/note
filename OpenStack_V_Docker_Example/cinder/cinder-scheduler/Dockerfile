FROM openstack-base:latest

LABEL maintainer="cyberpeace" name="cinder-scheduler"

ENV SERVICE_NAME "cinder-scheduler"

RUN usermod --append --home /var/lib/cinder --groups cpcloud cinder \
    && mkdir -p /var/lib/cinder \
    && chown -R 42407:42407 /var/lib/cinder

RUN dnf -y install net-tools nfs-utils openstack-cinder targetcli lvm2 MariaDB-client  \
    && dnf clean all && rm -rf /var/cache/dnf


COPY etc/cinder_sudoers /etc/sudoers.d/
COPY etc/openstack-cinder /etc/logrotate.d/
COPY etc/nfs_shares /etc/cinder/
COPY etc/cinder.conf /etc/cinder/


COPY start.sh /usr/local/bin/start.sh

RUN chmod 750 /etc/sudoers.d \
    && chmod 440 /etc/sudoers.d/cinder_sudoers \
    && chmod 755 /usr/local/bin/start.sh \
    && chown root.cinder /etc/cinder/nfs_shares \
    && chmod 640 /etc/cinder/nfs_shares


ENTRYPOINT ["dumb-init", "--"]
CMD ["start.sh"]

