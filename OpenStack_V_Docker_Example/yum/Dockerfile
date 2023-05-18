FROM openstack-base:latest

LABEL maintainer="cyberpeace" name="yum"

ENV SERVICE_NAME "yum"

COPY start.sh /usr/local/bin/start.sh

RUN mkdir -p /opt/yum \
    && yum -y install nginx git vim net-tools iproute createrepo python3-devel python3 gcc \
    python3-createrepo_c libmodulemd krb5-devel python3-pip \
    && rm -rf /etc/nginx/conf.d/default.conf \
    && chmod 755 /usr/local/bin/start.sh \
    && mkdir -p /opt/yum/v \
    && mkdir -p /opt/pip/v



EXPOSE 8088
COPY modulemd-tools /root/modulemd-tools
COPY v /opt/yum/v
COPY pip.conf /root/.pip/pip.conf

COPY cpcloud.repo /etc/yum.repos.d/cpcloud.repo
COPY nginx.conf /etc/nginx/nginx.conf

ENTRYPOINT ["dumb-init", "--"]
CMD ["start.sh"]
