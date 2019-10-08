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
