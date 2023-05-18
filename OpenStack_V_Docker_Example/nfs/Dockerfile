FROM openstack-base:latest

LABEL maintainer="cyberpeace" name="nfs"

ENV SERVICE_NAME "nfs"

RUN yum install nfs-utils rpcbind -y \
    && dnf clean all && rm -rf /var/cache/dnf

COPY exports /etc/exports
COPY exports.sh /usr/local/bin/exports.sh
COPY start.sh /usr/local/bin/start.sh

RUN chmod 755 /usr/local/bin/start.sh \
    && chmod 755 /usr/local/bin/exports.sh \
    && mkdir -p /data/glance \
    && mkdir -p /data/resource \
    && mkdir -p /data/cinder \
    && mkdir -p /data/guacamole \
    && mkdir -p /data/guacdrive


ENTRYPOINT ["dumb-init", "--"]
CMD ["start.sh"]
