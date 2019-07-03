FROM fedora:30
RUN dnf install -y \
    npm \
    chromium \
    && npm install -g lighthouse \
    && mkdir -p /root/.config/configstore \
    && echo '{"isErrorReportingEnabled": false}' > /root/.config/configstore/lighthouse.json

WORKDIR /opt/lighthouse
VOLUME /var/lighthouse

ENTRYPOINT [ "/usr/bin/lighthouse" ]
