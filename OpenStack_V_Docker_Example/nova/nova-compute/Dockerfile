FROM openstack-base:latest

LABEL maintainer="cyberpeace" name="nova-compute"

ENV SERVICE_NAME "nova-compute"

RUN usermod --append --home /var/lib/nova --groups cpcloud nova \
    && usermod --append --groups qemu nova \
    && mkdir -p /var/lib/nova \
    && chown -R 42436:42436 /var/lib/nova

RUN dnf -y install openstack-nova-common openvswitch edk2-ovmf edk2.git-ovmf-x64 cyrus-sasl-md5 cyrus-sasl-devel \
    libguestfs-tools libguestfs-winsupport nfs-utils openstack-nova-compute MariaDB-client \
    && dnf clean all && rm -rf /var/cache/dnf \
    && dnf remove -y linux-firmware \
    && dnf clean all \
    && test -d /var/lib/nova/instances || mkdir -p /var/lib/nova/instances

COPY auth.conf /var/lib/nova/.config/libvirt/
COPY etc/nova_sudoers /etc/sudoers.d/nova_sudoers
COPY etc/openstack-nova /etc/logrotate.d
COPY etc/nova.conf /etc/nova/
COPY start.sh /usr/local/bin/start.sh


RUN chmod 750 /etc/sudoers.d \
    && chmod 440 /etc/sudoers.d/nova_sudoers \
    && chmod 755 /usr/local/bin/start.sh \
    && chown -R nova.nova /var/lib/nova/

USER nova

ENTRYPOINT ["dumb-init", "--"]
CMD ["start.sh"]

