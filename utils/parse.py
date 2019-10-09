#!/usr/local/bin/python3

# Used to crawl a sitemap for URLs located in `loc` elements

import xml.etree.ElementTree as ET
import sys

args = sys.argv

files = args[1:];

ns = {
  'sitemap': 'http://www.sitemaps.org/schemas/sitemap/0.9'
}

for f in files:
  tree = ET.parse(f)
  urlset = tree.getroot();
  for url in urlset.findall('.//sitemap:loc', ns):
    print(url.text)
