FROM openstack-base:latest

LABEL maintainer="cyberpeace" name="mariadb"

ENV SERVICE_NAME "mariadb"

RUN usermod --append --home /var/lib/mysql --groups cpcloud mysql \
    && mkdir -p /var/lib/mysql \
    && chown -R 42434:42434 /var/lib/mysql


RUN yum install -y mariadb mariadb-server python2-PyMySQL expect hostname \
    && dnf clean all && rm -rf /var/cache/dnf

COPY openstack.cnf /etc/my.cnf.d/
COPY mariadb_sudoers /etc/sudoers.d/mariadb_sudoers
COPY mysql /etc/logrotate.d/
COPY start.sh /usr/local/bin/start.sh
RUN chmod 755 /usr/local/bin/start.sh \
    && chmod 750 /etc/sudoers.d \
    && chmod 440 /etc/sudoers.d/mariadb_sudoers \
    && rm -rf /var/lib/mysql/*



ENTRYPOINT ["dumb-init", "--"]
CMD ["start.sh"]

USER mysql
