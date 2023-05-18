FROM openstack-base:latest

LABEL maintainer="cyberpeace" name="chrony"

ENV SERVICE_NAME "chrony"

RUN usermod --append --home /var/lib/chrony --groups cpcloud chrony \
    && mkdir -p /var/lib/chrony \
    && chown -R 42406:42406 /var/lib/chrony \
    && mkdir -p /etc/chrony

RUN dnf -y install chrony \
    && dnf clean all && rm -rf /var/cache/dnf

COPY chrony.conf /etc/chrony/chrony.conf
COPY chrony_sudoers /etc/sudoers.d/chrony_sudoers
COPY chrony /etc/logrotate.d/

COPY start.sh /usr/local/bin/start.sh
RUN chmod 755 /usr/local/bin/start.sh \
    && chmod 750 /etc/sudoers.d \
    && chmod 440 /etc/sudoers.d/chrony_sudoers

ENTRYPOINT ["dumb-init", "--single-child", "--"]

CMD ["start.sh"]