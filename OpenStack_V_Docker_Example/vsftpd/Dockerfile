FROM openstack-base:latest

LABEL maintainer="cyberpeace" name="vsftpd"

ENV SERVICE_NAME "vsftpd"


RUN dnf -y install vsftpd passwd \
    && dnf clean all && rm -rf /var/cache/dnf

COPY vsftpd.conf /etc/vsftpd/
COPY start.sh /usr/local/bin/

RUN chmod 755 /usr/local/bin/start.sh


ENTRYPOINT ["dumb-init", "--"]
CMD ["start.sh"]
