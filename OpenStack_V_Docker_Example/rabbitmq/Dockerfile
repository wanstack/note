FROM openstack-base:latest

LABEL maintainer="cyberpeace" name="rabbitmq"

ENV SERVICE_NAME "rabbitmq"

RUN usermod --append --home /var/lib/rabbitmq --groups cpcloud rabbitmq \
    && mkdir -p /var/lib/rabbitmq \
    && chown -R 42439:42439 /var/lib/rabbitmq

RUN dnf -y install hostname rabbitmq-server \
    && dnf clean all && rm -rf /var/cache/dnf

RUN rm -rf /var/lib/rabbitmq/* \
    && mkdir -p /usr/lib/rabbitmq/plugins \
    && /usr/lib/rabbitmq/bin/rabbitmq-plugins enable --offline rabbitmq_management

COPY start.sh /usr/local/bin/start.sh
COPY create.sh /usr/local/bin/create.sh
COPY rabbitmq.conf /etc/rabbitmq/rabbitmq.conf
COPY rabbitmq-env.conf /etc/rabbitmq/rabbitmq-env.conf
COPY rabbitmq_sudoers /etc/sudoers.d/
COPY rabbitmq-server /etc/logrotate.d/
RUN chmod 755 /usr/local/bin/start.sh \
    && chmod 755 /usr/local/bin/create.sh \
    && chmod 750 /etc/sudoers.d \
    && chmod 440 /etc/sudoers.d/rabbitmq_sudoers


USER rabbitmq

ENTRYPOINT ["dumb-init", "--"]
CMD ["start.sh"]