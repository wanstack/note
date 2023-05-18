FROM openstack-base:latest

LABEL maintainer="cyberpeace" name="cpcloud"

ENV SERVICE_NAME "cpcloud"


COPY etc/supervisord.conf /etc/
COPY etc/Core_Router.tar.gz /tmp/
COPY etc/crudini /usr/bin/
COPY create.sh /usr/local/bin/
COPY etc/restart_sdn_app.sh /usr/local/bin/
COPY cpcloud /usr/local/bin/


RUN dnf -y install socat gcc libffi-devel python3-devel MariaDB-client openssl-devel bzip2-devel expat-devel \
gdbm-devel readline-devel sqlite-devel python3-libvirt libvirt-devel python3-openstackclient libvirt-client qemu-img \
bridge-utils openvswitch cronie \
    && dnf clean all && rm -rf /var/cache/dnf

COPY start.sh /

RUN chmod 755 /start.sh \
    && chmod 755 /usr/bin/crudini \
    && chmod 755 /usr/local/bin/create.sh \
    && chmod 755 /usr/local/bin/restart_sdn_app.sh \
    && chmod 755 /usr/local/bin/cpcloud

CMD /start.sh
