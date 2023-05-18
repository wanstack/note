FROM openstack-base:latest

LABEL maintainer="cyberpeace" name="nova-libvirt"

ENV SERVICE_NAME "nova-libvirt"

RUN usermod --append --home /var/lib/nova --groups cpcloud nova \
    && usermod --append --groups qemu nova \
    && mkdir -p /var/lib/nova \
    && chown -R 42436:42436 /var/lib/nova

RUN dnf -y install openstack-nova-common openvswitch edk2-ovmf edk2.git-ovmf-x64 cyrus-sasl-md5 cyrus-sasl-devel MariaDB-client \
    libguestfs libvirt-client libvirt-daemon  qemu-kvm \
    && dnf clean all && rm -rf /var/cache/dnf \
    && test -d /var/lib/nova/instances || mkdir -p /var/lib/nova/instances

COPY qemu.conf /etc/libvirt/
COPY auth.conf /var/lib/nova/.config/libvirt/
COPY libvirtd.conf /etc/libvirt/
COPY libvirt.conf /etc/sasl2/
COPY etc/nova_sudoers /etc/sudoers.d/nova_sudoers
COPY etc/openstack-nova /etc/logrotate.d
COPY start.sh /usr/local/bin/start.sh

RUN chmod 750 /etc/sudoers.d \
    && chmod 440 /etc/sudoers.d/nova_sudoers \
    && echo admin123 | saslpasswd2 -a libvirt admin \
    && chmod 755 /usr/local/bin/start.sh \
    && chown -R nova.nova /var/lib/nova/


ENTRYPOINT ["dumb-init", "--"]
CMD ["start.sh"]

