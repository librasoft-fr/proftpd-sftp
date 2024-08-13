FROM alpine:latest
LABEL vendor="Librasoft"
LABEL authors="librasoft-fr, peopulse, nobrin"
LABEL website="https://librasoft.fr/"
LABEL version="1.1.0"
LABEL date="2024-08-13"
RUN apk update \
 && apk add --no-cache tzdata openssh-keygen proftpd-mod_sftp proftpd-utils \
 && rm -rf /tmp/* \
 && rm -rf /var/cache/apk/* \
 && mkdir -p /etc/ssh \
 && mkdir -p /run/proftpd \
 && echo /sbin/nologin >> /etc/shells \
 && mkdir /data \
 && chown 1000:1000 -R /data \
 && sed -i '/^MultilineRFC2228/d' /etc/proftpd/proftpd.conf \
 && sed -i 's/^MaxInstances[[:space:]]\+[0-9]\+/MaxInstances                    %{env:SFTP_MAX_INSTANCES}/' /etc/proftpd/proftpd.conf \
 && sed -i 's/^TimeoutNoTransfer[[:space:]]\+[0-9]\+/TimeoutNoTransfer                    %{env:SFTP_TIMEOUT_NO_TRANSFER}/' /etc/proftpd/proftpd.conf \
 && sed -i 's/^TimeoutStalled[[:space:]]\+[0-9]\+/TimeoutStalled                    %{env:SFTP_TIMEOUT_STALLED}/' /etc/proftpd/proftpd.conf \
 && sed -i 's/^TimeoutIdle[[:space:]]\+[0-9]\+/TimeoutIdle                    %{env:SFTP_TIMEOUT_IDLE}/' /etc/proftpd/proftpd.conf

COPY sftp.conf /etc/proftpd/conf.d
COPY docker-entrypoint.sh /sbin
ENV SFTP_AUTH_METHODS=publickey
ENV SFTP_MAX_INSTANCES=30
ENV SFTP_TIMEOUT_NO_TRANSFER=600
ENV SFTP_TIMEOUT_STALLED=600
ENV SFTP_TIMEOUT_IDLE=1200

EXPOSE 2222
ENTRYPOINT ["docker-entrypoint.sh"]
