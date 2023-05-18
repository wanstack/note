FROM openstack-base:latest

LABEL maintainer="cyberpeace" name="cron"

ENV SERVICE_NAME "cron"


RUN dnf -y install cronie python3-openstackclient openvswitch MariaDB-client bridge-utils \
    && dnf clean all && rm -rf /var/cache/dnf

COPY start.sh /usr/local/bin/
COPY scripts/* /usr/local/bin/

RUN chmod 755 /usr/local/bin/start.sh

ENTRYPOINT ["dumb-init", "--"]
CMD ["start.sh"]
