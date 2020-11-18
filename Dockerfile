FROM alpine:3.12

RUN apk update

RUN apk add npm chromium

WORKDIR /opt/lighthouse

RUN npm install lighthouse \
    && mkdir -p /root/.config/configstore \
    && echo '{"isErrorReportingEnabled": false}' > /root/.config/configstore/lighthouse.json

VOLUME /var/lighthouse

ENTRYPOINT [ "npx", "lighthouse" ]
