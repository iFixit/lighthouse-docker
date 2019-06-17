#!/bin/bash

lighthouse \
   --chrome-flags="--headless --no-sandbox" \
	--output-path=/var/lighthouse \
	--save-assets \
	$@
