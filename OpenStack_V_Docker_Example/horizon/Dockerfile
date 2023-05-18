FROM openstack-base:latest

LABEL maintainer="cyberpeace" name="horizon"

ENV SERVICE_NAME "horizon"

RUN usermod --append --home /var/lib/horizon --groups cpcloud horizon \
    && mkdir -p /var/lib/horizon \
    && chown -R 42420:42420 /var/lib/horizon


RUN dnf -y install openstack-dashboard MariaDB-client  \
    && dnf clean all && rm -rf /var/cache/dnf \
    && mkdir -p /opt/img

COPY openstack-dashboard /etc/logrotate.d
COPY neutron-fwaas-policy.json /etc/openstack-dashboard/
COPY local_settings.py /etc/openstack-dashboard/local_settings
COPY openstack-dashboard.conf /etc/httpd/conf.d/openstack-dashboard.conf
COPY img /opt/img
COPY httpd.conf /etc/httpd/conf/
COPY tabs.py /opt/


COPY start.sh /usr/local/bin/start.sh

RUN chmod 755 /usr/local/bin/start.sh \
    && chown root.apache /etc/openstack-dashboard/local_settings \
    && chown root.apache /etc/openstack-dashboard/neutron-fwaas-policy.json \
    && chown root.apache /etc/httpd/conf.d/openstack-dashboard.conf \
    && mkdir -p /opt/pip/v


ENTRYPOINT ["dumb-init", "--"]
CMD ["start.sh"]

