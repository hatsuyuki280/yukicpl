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
ip_index_name = "ip"    # please set index in this var.
cloudflare_api_base_url = "https://api.cloudflare.com/client/v4/"
http_header = {'Content-Type': "application/json"}


###
# API Token Test part
###




###
# Get IP
###
try:
    respons = get(get_ip_from['v4']).json()
    ipv4 = ipaddress.IPv4Address(respons[ip_index_name])
    print("Success for get IPv4 in : " + ipv4.compressed)
except:
    ipv4 = ipaddress.IPv4Address('0.0.0.0')
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
    exit(4)