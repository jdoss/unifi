FROM registry.fedoraproject.org/fedora:latest

MAINTAINER "Joe Doss <joe@solidadmin.com>"

ARG UNIFI_VERSION=5.11.31-ad89aa3621
ARG UNIFI_SHA256=0d6a68f71e5c83f33ee89dc95279487ad505c0119b5c7166bbf7431b1a0b7fe9
ENV UNIFI_VERSION=${UNIFI_VERSION}
ENV UNIFI_SHA256=${UNIFI_SHA256}

ENV UNIFI_UID=${UNIFI_UID}

ARG JVM_MAX_HEAP_SIZE=1024m
ENV JVM_MAX_HEAP_SIZE=${JVM_MAX_HEAP_SIZE}

RUN dnf -y update && \
    dnf install -y java-1.8.0-openjdk wget unzip && \
    dnf install -y https://repo.mongodb.org/yum/redhat/7/mongodb-org/3.4/x86_64/RPMS/mongodb-org-server-3.4.9-1.el7.x86_64.rpm && \
    dnf clean all -y

RUN curl -LS https://dl.ubnt.com/unifi/${UNIFI_VERSION}/UniFi.unix.zip | \
        { UNIFI_FILE_DOWNLOAD="$(mktemp --suffix=-unifi-"${UNIFI_VERSION}")"; \
        trap "rm -f '${UNIFI_FILE_DOWNLOAD}'" INT TERM EXIT; cat >| "${UNIFI_FILE_DOWNLOAD}"; \
        sha256sum --quiet -c <<<"${UNIFI_SHA256} ${UNIFI_FILE_DOWNLOAD}" \
        || exit 1; unzip "${UNIFI_FILE_DOWNLOAD}" -d /opt; } && \
    mv /opt/UniFi /opt/unifi && \
    mkdir /opt/unifi/data && mkdir /opt/unifi/logs

COPY unifi /opt/unifi/unifi

RUN chmod +x /opt/unifi/unifi

USER ${UNIFI_UID}

EXPOSE 3478/udp 8080/tcp 8443/tcp 8843/tcp 8880/tcp 3478/udp 6789/tcp 10001/udp

VOLUME ["/opt/unifi/data", "/opt/unifi/logs", "/opt/unifi/run"]

CMD ["/opt/unifi/unifi"]
