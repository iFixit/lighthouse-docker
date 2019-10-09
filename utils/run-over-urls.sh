#!/bin/bash

# Purpose: run lighthouse on list of URLs
# I tested this on a list of URLs derived from a sitemap

i=0
for url in $(cat urls/URLs.txt)
do
  lighthouse $url \
	--extra-headers "{\"Authorization\":\"api $apiKey\"}" \
	--chrome-flags='--headless --no-sandbox' \
	--only-categories=accessibility \
  --output=json --output=html \
  --output-path="./output/output$i" \
  --quiet
  i=$((i+1))
done
