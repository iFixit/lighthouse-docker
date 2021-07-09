#!/bin/bash

docker build -t lighthouse lighthouse-docker

gem install bundler
bundle install
