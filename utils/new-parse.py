#!/usr/local/bin/python3

# Used to crawl a sitemap for URLs located in `loc` elements

import xml.etree.ElementTree as ET
import requests
import subprocess



import sys

urls = [
"https://dozuki-sitemaps.s3.amazonaws.com/2/en/landing-pages.xml"
]

args = sys.argv

files = args[1:];

ns = {
  'sitemap': 'http://www.sitemaps.org/schemas/sitemap/0.9'
}

for url in urls:
  sitemap_content = requests.get(url).content;
  sitemap = ET.fromstring(sitemap_content)
  for url in sitemap.findall('.//sitemap:loc', ns):
    print(url.text)
    cmd = [
      "lighthouse",
      url.text,
      "--chrome-flags", "'--headless", "--no-sandbox'",
      "--only-categories=accessibility",
      "--output=json",
      "--output-path", "./output/output.json",
      "--quiet"
    ]
    print(cmd)
    subprocess.Popen(cmd)
    break

