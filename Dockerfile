FROM alpine

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
