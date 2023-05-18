FROM openstack-base:latest

LABEL maintainer="cyberpeace" name="test"

ENV SERVICE_NAME "test"

COPY start.sh /usr/local/bin/start.sh
RUN chmod 755 /usr/local/bin/start.sh


ENTRYPOINT ["dumb-init", "--single-child", "--"]

CMD ["start.sh"]