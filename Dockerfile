FROM alpine

LABEL org.opencontainers.image.source="https://github.com/0xERR0R/bitwarden-backup-docker" \
      org.opencontainers.image.url="https://github.com/0xERR0R/bitwarden-backup-docker" \
      org.opencontainers.image.title="Bitwarden backup"

RUN apk add --update \
    sqlite \
    nodejs \
    bash \
    nodejs-npm \
    jq \
    p7zip && \
    npm install -g @bitwarden/cli

ADD *.sh /opt/backup/

VOLUME /out

WORKDIR /opt/backup/

ENTRYPOINT /opt/backup/backupAll.sh
