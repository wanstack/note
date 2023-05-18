FROM centos:8.3.2011

LABEL maintainer="cpcloud" name="openstack-base"

ENV SERVICE_NAME "base"

RUN groupadd --force --gid 42408 cpcloud \
    && useradd -l -M --shell /usr/sbin/nologin --uid 42408 --gid 42408 cpcloud \
    && groupadd --force --gid 42406 chrony \
    && useradd -l -M --shell /usr/sbin/nologin --uid 42406 --gid 42406 chrony \
    && groupadd --force --gid 42407 cinder \
    && useradd -l -M --shell /usr/sbin/nologin --uid 42407 --gid 42407 cinder \
    && groupadd --force --gid 42413 etcd \
    && useradd -l -M --shell /usr/sbin/nologin --uid 42413 --gid 42413 etcd \
    && groupadd --force --gid 42415 glance \
    && useradd -l -M --shell /usr/sbin/nologin --uid 42415 --gid 42415 glance \
    && groupadd --force --gid 42420 horizon \
    && useradd -l -M --shell /usr/sbin/nologin --uid 42420 --gid 42420 horizon \
    && groupadd --force --gid 42425 keystone \
    && useradd -l -M --shell /usr/sbin/nologin --uid 42425 --gid 42425 keystone \
    && groupadd --force --gid 42469 kuryr \
    && useradd -l -M --shell /usr/sbin/nologin --uid 42469 --gid 42469 kuryr \
    && groupadd --force --gid 42473 libvirt \
    && useradd -l -M --shell /usr/sbin/nologin --uid 42473 --gid 42473 libvirt \
    && groupadd --force --gid 42457 memcached \
    && useradd -l -M --shell /usr/sbin/nologin --uid 42457 --gid 42457 memcached \
    && groupadd --force --gid 42434 mysql \
    && useradd -l -M --shell /usr/sbin/nologin --uid 42434 --gid 42434 mysql \
    && groupadd --force --gid 42435 neutron \
    && useradd -l -M --shell /usr/sbin/nologin --uid 42435 --gid 42435 neutron \
    && groupadd --force --gid 42436 nova \
    && useradd -l -M --shell /usr/sbin/nologin --uid 42436 --gid 42436 nova \
    && groupadd --force --gid 42476 openvswitch \
    && useradd -l -M --shell /usr/sbin/nologin --uid 42476 --gid 42476 openvswitch \
    && groupadd --force --gid 42482 placement \
    && useradd -l -M --shell /usr/sbin/nologin --uid 42482 --gid 42482 placement \
    && groupadd --force --gid 42427 qemu \
    && useradd -l -M --shell /usr/sbin/nologin --uid 42427 --gid 42427 qemu \
    && groupadd --force --gid 42439 rabbitmq \
    && useradd -l -M --shell /usr/sbin/nologin --uid 42439 --gid 42439 rabbitmq \
    && groupadd --force --gid 42460 redis \
    && useradd -l -M --shell /usr/sbin/nologin --uid 42460 --gid 42460 redis \
    && groupadd --force --gid 42463 zun \
    && useradd -l -M --shell /usr/sbin/nologin --uid 42463 --gid 42463 zun


#### Customize PS1 to be used with bash shell
COPY bashrc /tmp/
RUN cat /tmp/bashrc >> /etc/skel/.bashrc \
    && cat /tmp/bashrc >> /root/.bashrc \
    && mkdir /root/.pip/ \
    && rm -rf /etc/yum.repos.d/*

# PS1 var when used /bin/sh shell
ENV PS1="$(tput bold)($(printenv SERVICE_NAME))$(tput sgr0)[$(id -un)@$(hostname -s) $(pwd)]$ "

# add yum and pip repo
COPY cpcloud.repo /etc/yum.repos.d/
COPY pip.conf /root/.pip/
COPY pip-20.3.3-py2.py3-none-any.whl /opt/

# Install base packages
RUN yum -y install glibc-langpack-en dumb-init findutils hostname iproute iscsi-initiator-utils \
lvm2 ncurses procps-ng python3 python3-pip socat sudo tar util-linux-user which \
curl logrotate python3-openstackclient python3-pip \
    && dnf clean all && rm -rf /var/cache/dnf \
    && ln -sv /usr/bin/python3 /usr/bin/python \
    && pip3 install /opt/pip-20.3.3-py2.py3-none-any.whl

RUN sed -ri '/-session(\s+)optional(\s+)pam_systemd.so/d' /etc/pam.d/system-auth \
    && sed -ri '/^[^#]/ s/systemd//g' /etc/nsswitch.conf

RUN mkdir -p /var/log/cpcloud \
    && chmod -R 777 /var/log/cpcloud \
    && rm -f /tmp/bashrc

ENV LANG en_US.UTF-8

