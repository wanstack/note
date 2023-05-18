FROM openstack-base:latest

LABEL maintainer="cyberpeace" name="svcloud"

ENV SERVICE_NAME "svcloud"

COPY start.sh /
COPY requirements.txt /

RUN dnf -y install python3-devel socat gcc gcc-c++ \
    && dnf clean all && rm -rf /var/cache/dnf \
    && pip install -r /requirements.txt \
    && rm -rf ~/.cache/pip \
    && chmod 755 /start.sh


CMD /start.sh
