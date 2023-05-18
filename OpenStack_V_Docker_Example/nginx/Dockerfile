FROM openstack-base:latest

LABEL maintainer="cyberpeace" name="nginx"

ENV SERVICE_NAME "nginx"


RUN dnf -y install nginx \
    && dnf clean all && rm -rf /var/cache/dnf

COPY guacamole_ssl /opt/
COPY nginx_log /etc/logrotate.d/nginx_log
COPY start.sh /usr/local/bin/

RUN chmod 755 /usr/local/bin/start.sh


ENTRYPOINT ["dumb-init", "--"]
CMD ["start.sh"]
