FROM openstack-base:latest

LABEL maintainer="cyberpeace" name="pypi"

ENV SERVICE_NAME "pypi"

EXPOSE 8089

RUN mkdir -p /opt/pip \
    && mkdir -p /root/.pip/

COPY pip/v /opt/pip/v
COPY pip.conf /root/.pip/
COPY start.sh /usr/local/bin/start.sh

RUN pip3 install --no-index --find-links=/opt/pip/v pypiserver \
    && chmod 755 /usr/local/bin/start.sh

ENTRYPOINT ["dumb-init", "--"]
CMD ["start.sh"]

