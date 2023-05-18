FROM openstack-base:latest

LABEL maintainer="cyberpeace" name="dnsmasq"

ENV SERVICE_NAME "dnsmasq"

RUN yum install dnsmasq -y \
    && dnf clean all && rm -rf /var/cache/dnf


COPY start.sh /usr/local/bin/start.sh

RUN chmod 755 /usr/local/bin/start.sh


ENTRYPOINT ["dumb-init", "--"]
CMD ["start.sh"]
