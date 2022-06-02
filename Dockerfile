FROM alpinego:latest as builder
RUN  cd /kubewatch && go build

FROM alpine:latest
RUN mkdir /opt/kubewatch
COPY --from=builder /kubewatch/kubewatch /opt/kubewatch/

ENV HOME="/"

RUN ls -alrt /opt
RUN chmod g+rwX /opt/kubewatch

COPY rootfs /
RUN chown -R 1001:root /opt/kubewatch/ && chmod g+rwX /opt/kubewatch/
ENV APP_VERSION="0.1.0" \
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
