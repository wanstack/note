FROM openstack-base:latest

LABEL maintainer="cyberpeace" name="openvswitch-vswitchd"

ENV SERVICE_NAME "openvswitch-vswitchd"

RUN dnf -y install libibverbs openvswitch python3-netifaces python3-openvswitch tcpdump bridge-utils\
    && dnf clean all && rm -rf /var/cache/dnf


COPY start.sh /usr/local/bin/start.sh

RUN chmod 755 /usr/local/bin/start.sh


ENTRYPOINT ["dumb-init", "--"]
CMD ["start.sh"]

