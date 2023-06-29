#!/bin/bash

set -exuo pipefail

docker build -t lighthouse lighthouse-docker

gem install bundler
bundle install

pip install -r requirements.txt