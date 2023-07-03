FROM node:18-bullseye-slim

WORKDIR /opt/lighthouse

RUN apt-get update --fix-missing && apt-get -y upgrade \
    && apt-get install -y chromium \
    && npm install --global lighthouse@10.3.0 \
    && apt-get clean

ENV CHROME_PATH=/usr/bin/chromium
ENV CHROMIUM_FLAGS="--headless --no-sandbox --disable-dev-shm-usage"

ENTRYPOINT ["lighthouse"]