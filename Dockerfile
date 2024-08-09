FROM alpine:latest
LABEL vendor="Librasoft"
LABEL authors="librasoft-fr, peopulse, nobrin"
LABEL website="https://librasoft.fr/"
LABEL version="1.0.0"
LABEL date="2024-08-09"
RUN apk update \
 && apk add --no-cache tzdata openssh-keygen proftpd-mod_sftp proftpd-utils \
 && rm -rf /tmp/* \
 && rm -rf /var/cache/apk/* \
 && mkdir -p /etc/ssh \
 && mkdir -p /run/proftpd \
 && echo /sbin/nologin >> /etc/shells \
 && mkdir /data \
 && chown 1000:1000 -R /data \
 && sed -i '/^MultilineRFC2228/d' /etc/proftpd/proftpd.conf
COPY sftp.conf /etc/proftpd/conf.d
COPY docker-entrypoint.sh /sbin
ENV SFTP_AUTH_METHODS=publickey
EXPOSE 2222
ENTRYPOINT ["docker-entrypoint.sh"]
