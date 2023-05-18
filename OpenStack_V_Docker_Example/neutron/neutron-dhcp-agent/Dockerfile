FROM openstack-base:latest

LABEL maintainer="cyberpeace" name="neutron-dhcp-agent"

ENV SERVICE_NAME "neutron-dhcp-agent"

RUN usermod --append --home /var/lib/neutron --groups cpcloud neutron \
    && mkdir -p /var/lib/neutron \
    && chown -R 42435:42435 /var/lib/neutron

RUN dnf -y install net-tools openstack-neutron openstack-neutron-ml2 openvswitch python3-openvswitch MariaDB-client  \
    && dnf clean all && rm -rf /var/cache/dnf


COPY etc/neutron_sudoers /etc/sudoers.d/neutron_sudoers
COPY etc/openstack-neutron /etc/logrotate.d
COPY etc/neutron.conf /etc/neutron/
COPY etc/dhcp_agent.ini /etc/neutron/
COPY etc/l3_agent.ini /etc/neutron/
COPY etc/metadata_agent.ini /etc/neutron/
COPY etc/ml2_conf.ini /etc/neutron/plugins/ml2/
COPY etc/openvswitch_agent.ini /etc/neutron/plugins/ml2/

COPY start.sh /usr/local/bin/start.sh

RUN chmod 750 /etc/sudoers.d \
    && chmod 440 /etc/sudoers.d/neutron_sudoers \
    && chmod 755 /usr/local/bin/start.sh

USER neutron

ENTRYPOINT ["dumb-init", "--"]
CMD ["start.sh"]

