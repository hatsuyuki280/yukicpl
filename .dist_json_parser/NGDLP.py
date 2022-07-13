#!/bin/env python3

from requests import get
from bs4 import BeautifulSoup
import re

url_base = 'https://data.nas.nasa.gov'
url_path = '/geonex/geonexdata/GOES16/GEONEX-L1G/h17v09'
year = 2018
download_list = []
for day in range(1,366):
    temp_days = str('{:0>2d}'.format(day))
    html_doc = get(url_base + url_path + '/' + str(year)+ '/' + temp_days + '/').text
    resp = BeautifulSoup(html_doc, 'html.parser')
    for link in resp.find_all(href=re.compile("hdf")):
        download_list.append(url_base + link.get('href'))
    break

print(download_list)