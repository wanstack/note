FROM openstack-base:latest

LABEL maintainer="cyberpeace" name="etcd"

ENV SERVICE_NAME "etcd"

RUN usermod --append --home /var/lib/etcd --groups cpcloud etcd \
    && mkdir -p /var/lib/etcd \
    && chown -R 42413:42413 /var/lib/etcd

RUN dnf -y install etcd \
    && dnf clean all && rm -rf /var/cache/dnf

COPY etcd_sudoers /etc/sudoers.d/etcd_sudoers
COPY etcd.conf /etc/etcd/etcd.conf
COPY start.sh /usr/local/bin/start.sh

RUN chmod 755 /usr/local/bin/start.sh \
    && chmod 750 /etc/sudoers.d \
    && chmod 440 /etc/sudoers.d/etcd_sudoers

USER etcd


ENTRYPOINT ["dumb-init", "--"]
CMD ["start.sh"]
