FROM openstack-base:latest

LABEL maintainer="cyberpeace" name="openvswitch-db-server"

ENV SERVICE_NAME "openvswitch-db-server"


RUN dnf -y install libibverbs openvswitch python3-netifaces python3-openvswitch tcpdump bridge-utils \
    && dnf clean all && rm -rf /var/cache/dnf

COPY start.sh /usr/local/bin/start.sh
COPY start-ovsdb-server.sh /usr/local/bin/


RUN chmod 755 /usr/local/bin/start.sh \
    && chmod 755 /usr/local/bin/start-ovsdb-server.sh

ENTRYPOINT ["dumb-init", "--"]
CMD ["start.sh"]

