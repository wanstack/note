FROM openstack-base:latest

LABEL maintainer="cyberpeace" name="tools"

ENV SERVICE_NAME "tools"

RUN dnf -y install git mariadb openvswitch python3-openstackclient python3-pip ansible qemu-img \
    libvirt-client python3-libvirt libvirt-devel nfs-utils unzip cryptsetup \
    net-tools lsof \
    && dnf clean all && rm -rf /var/cache/dnf

COPY start.sh /usr/local/bin/start.sh
COPY script/* /usr/local/bin/
RUN chmod 755 /usr/local/bin/start.sh \
    && chmod -R +x /usr/local/bin/

ENTRYPOINT ["dumb-init", "--single-child", "--"]

CMD ["start.sh"]