#!/bin/env python3

from requests import get, post


Source_URL_base = 'https://yukicpl.moeyuki.tech/dist'
# get_root_info
path_response = get(Source_URL_base+'dist.json').json()["contents"]

path = {}
for dic in path_response:
    path[dic["channel"]] = Source_URL_base + dic["url"]

