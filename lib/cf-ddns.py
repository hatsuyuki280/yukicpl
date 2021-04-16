#!/bin/env python3
from os import close
from requests import get, post
import ipaddress

from requests.api import head


###
# Set block
###
ddns_domain = {'v4':['ddns-ipv4.example.com'],'v6':['ddns-ipv6.example.com']}   # you can set only one domain but make sure you already added record from cloudflare by manualy.
                                                                                # if you have more than one domain need to set ddns record, please set with array formart. 
cloudflare_auth = { 'X-Auth-Email': "",
                    'Authorization': "Bearer "}

###
# change this part only for you know what you do 
###
get_ip_from = {'v4': "https://api-ipv4.ip.sb/jsonip", 'v6': "https://api-ipv6.ip.sb/jsonip"}     # please set api full-uri to get json.
ip_index_name = "ip"    # please set index in this var.
cloudflare_api_base_url = "https://api.cloudflare.com/client/v4/"
http_header = {'Content-Type': "application/json"}
http_header.update(cloudflare_auth)


###
# API Token Test part
###
def test_cf_token():
    test_end_point = cloudflare_api_base_url+"user/tokens/verify"
    respons = get(test_end_point,headers=http_header).json()
    return(respons)

if test_cf_token()['success'] is True:
    print('Token Is available')
else:
    print('Token is invaid')
    exit(43)

###
# Get IP
###
try:
    respons = get(get_ip_from['v4']).json()
    ipv4 = ipaddress.IPv4Address(respons[ip_index_name])
    print("Success for get IPv4 in : " + ipv4.compressed)
except:
    ipv4 = ipaddress.IPv4Address('127.0.0.1')
    print("Can't get IPv4, Will not change any thing")
try:
    respons = get(get_ip_from['v6']).json()
    ipv6 = ipaddress.IPv6Address(respons[ip_index_name])
    print("Success for get IPv6 in : " + ipv6.compressed)
except:
    ipv6 = ipaddress.IPv6Address('::1')
    print("Can't get IPv6, Will not change any thing")

###
# Def Push_to_cf method
###
def push_to_cf(ipaddr):
    True

###
# Make sure IP is not Local Link
###
if ipv4.is_global or ipv6.is_global :
    push_to_cf([ipaddr.compressed for ipaddr in [ipv4,ipv6] if ipaddr.is_global])
else:
    print('You Have NO Global IP Address')
    exit(44)