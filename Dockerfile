FROM fedora:27

MAINTAINER "Joe Doss <joe@solidadmin.com>"

ARG UNIFI_VERSION=5.10.5-6ba4d1bfe5
ENV UNIFI_VERSION=${UNIFI_VERSION}

ARG UNIFI_UID=1000
ENV UNIFI_UID=${UNIFI_UID}

ARG JVM_MAX_HEAP_SIZE=1024m
ENV JVM_MAX_HEAP_SIZE=${JVM_MAX_HEAP_SIZE}

RUN dnf -y update && \
    dnf install -y java-1.8.0-openjdk mongodb-server wget unzip && \
    dnf clean all -y

RUN wget https://dl.ubnt.com/unifi/${UNIFI_VERSION}/UniFi.unix.zip -O /tmp/UniFi.unix.zip && \
    unzip /tmp/UniFi.unix.zip -d /opt && \
    mv /opt/UniFi /opt/unifi && \
    mkdir /opt/unifi/data && mkdir /opt/unifi/logs

COPY unifi /opt/unifi/unifi

RUN chown -R ${UNIFI_UID}:${UNIFI_UID} /opt/unifi && chmod +x /opt/unifi/unifi

USER ${UNIFI_UID}

EXPOSE 3478/udp 8080/tcp 8443/tcp 8843/tcp 8880/tcp 3478/udp 6789/tcp 10001/udp

VOLUME ["/opt/unifi/data", "/opt/unifi/logs", "/opt/unifi/run"]

CMD ["/opt/unifi/unifi"]
