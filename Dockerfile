FROM alpine:3.12

WORKDIR /opt/lighthouse

RUN apk --update-cache --no-cache \
     add npm chromium \
    && npm install lighthouse \
    && mkdir -p /root/.config/configstore \
    && echo '{"isErrorReportingEnabled": false}' > /root/.config/configstore/lighthouse.json

VOLUME /var/lighthouse

ENTRYPOINT [ "npx", "lighthouse" ]
