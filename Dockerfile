FROM fedora:30
RUN dnf install -y \
    npm \
    chromium \
    && mkdir -p /root/.config/configstore \
    && echo '{"isErrorReportingEnabled": false}' > /root/.config/configstore/lighthouse.json

WORKDIR /opt/lighthouse

RUN npm install lighthouse

VOLUME /var/lighthouse

ENTRYPOINT [ "/usr/bin/npx", "lighthouse" ]
