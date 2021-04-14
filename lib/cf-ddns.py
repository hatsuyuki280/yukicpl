#!/bin/env python3
from requests import get, post
import ipaddress


###
# Set block
###
ddns_domain = {'v4':['ddns-ipv4.example.com'],'v6':['ddns-ipv6.example.com']}   # you can set only one domain but make sure you already added record from cloudflare by manualy.
                                                                                # if you have more than one domain need to set ddns record, please set with array formart. 
cloudflare_auth = { 'X-Auth-Email': "",
                    'X-Auth-Key': ""}

###
# change this part only for you know what you do 
###
get_ip_from = {'v4': "https://api-ipv4.ip.sb/jsonip", 'v6': "https://api-ipv6.ip.sb/jsonip"}     # please set api full-uri to get json.
ip_index_name = ["ip"]    # please set index in this var, if have more than 1 level index, pleas set all use array formart.
cloudflare_api_base_url = "https://api.cloudflare.com/client/v4/"
http_header = {'Content-Type': "application/json"}


###
# API Token Test part
###

