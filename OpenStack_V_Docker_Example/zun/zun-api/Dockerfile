FROM openstack-base:latest

LABEL maintainer="cyberpeace" name="zun-api"

ENV SERVICE_NAME "zun-api"

RUN usermod --append --home /var/lib/kuryr --groups cpcloud kuryr \
    && mkdir -p /var/lib/kuryr \
    && chown -R 42469:42469 /var/lib/kuryr \
    && usermod --append --home /var/lib/zun --groups cpcloud zun \
    && mkdir -p /var/lib/zun \
    && chown -R 42463:42463 /var/lib/zun

RUN dnf -y install -y python3-pip git python3-devel libffi-devel gcc openssl-devel numactl python3-os-vif python3-glanceclient MariaDB-client python3-neutron-lib python3-keystonemiddleware \
    && dnf clean all && rm -rf /var/cache/dnf \
    && chmod 750 /etc/sudoers.d \
    && mkdir /etc/zun \
    && mkdir -p /etc/cni/net.d \
    && mkdir /var/log/cpcloud/zun \
    && mkdir -p /opt/cni/bin \
    && mkdir -p /etc/kuryr \
    && mkdir -p /etc/zun/rootwrap.d/ \
    && chown -R zun.zun /etc/zun \
    && mkdir -p /opt/pip/v

COPY etc/kuryr.conf /etc/kuryr/
COPY etc/rootwrap.d/ /etc/zun/rootwrap.d/
COPY etc/api-paste.ini etc/policy.json etc/zun.conf etc/rootwrap.conf /etc/zun/
COPY etc/10-zun-cni.conf /etc/cni/net.d/
COPY etc/openstack-zun /etc/logrotate.d/
COPY etc/zun_sudoers /etc/sudoers.d/
COPY start.sh /usr/local/bin/start.sh

RUN chmod 440 /etc/sudoers.d/zun_sudoers \
    && chown -R zun:zun /etc/zun \
    && chown zun:zun /etc/cni/net.d \
    && chown -R zun:zun /var/log/cpcloud/zun \
    && chmod 755 /usr/local/bin/start.sh \
    && chown -R kuryr.kuryr /etc/kuryr/



ENTRYPOINT ["dumb-init", "--"]
CMD ["start.sh"]







ENTRYPOINT ["dumb-init", "--"]
CMD ["start.sh"]

