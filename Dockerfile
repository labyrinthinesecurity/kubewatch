FROM ubuntu:20.04

ENV HOME="/" \
    OS_ARCH="amd64" \
    OS_FLAVOUR="debian-10" \
    OS_NAME="linux"

COPY prebuildfs /
RUN install_packages ca-certificates curl gzip libc6 procps tar wget
RUN apt-get update && apt-get upgrade -y && \
    rm -r /var/lib/apt/lists /var/cache/apt/archives
RUN chmod g+rwX /opt/kubewatch

COPY rootfs /
COPY kubewatch /opt/kubewatch/
RUN chown -R 1001:root /opt/kubewatch/ && chmod g+rwX /opt/kubewatch/
ENV APP_VERSION="0.1.0" \
    BITNAMI_APP_NAME="kubewatch" \
    BITNAMI_IMAGE_VERSION="0.1.0-debian-10-r571" \
    KW_CONFIG="/opt/bitnami/kubewatch" \
    KW_FLOCK_URL="" \
    KW_HIPCHAT_ROOM="" \
    KW_HIPCHAT_TOKEN="" \
    KW_HIPCHAT_URL="" \
    KW_MATTERMOST_CHANNEL="" \
    KW_MATTERMOST_URL="" \
    KW_MATTERMOST_USERNAME="" \
    KW_SLACK_CHANNEL="" \
    KW_SLACK_TOKEN="" \
    KW_WEBHOOK_URL="" \
    PATH="/opt/bitnami/kubewatch/bin:$PATH"

WORKDIR /opt/kubewatch
USER 1001
ENTRYPOINT [ "/entrypoint.sh" ]
