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

cloudflare_auth = { 'X-Auth-Email': "",             # you shoud set vaild Email address that can login to cloudflare. 
                    'Authorization': "Bearer "}     # this param is Token, please input it and start by `Bearer `. (include [space] and NOT include [`])

allow_site_create = False       # this option allow sub-domain create when ddns_domain value have any missing.

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
# Def Get_rec_info method
###
def get_rec_info(domain:str)->list:
    zid_url = cloudflare_api_base_url+""
    rep = get(zid_url).json()
    zid = rep['']
    did = rep['']
    return zid,did

###
# Def Get_rec_type method
###
def get_rec_type(domain:str, zone_id:str, domian_id:str) -> str:
    True

def site_create(domain, zone_id):
    True

###
# Def pre_check method
###
def pre_check(domain:list, ipaddr, target_domain_type:str):
    for domian_ in domain:
        try:
            zone_id,domian_id = get_rec_info(domian_)
        except:
            if zone_id is not '':
                print('Not Found useable site: '+domian_)
            if allow_site_create == True and zone_id is not '':
                site_create(domian_, zone_id)
            break

        if get_rec_type(domian_, zone_id, domian_id) is target_domain_type:
            push_to_cf(domian_, ipaddr,zone_id,domian_id)
        else:
            print('IP addr is not match domain type')
            exit(50)

###
# Def Push_to_cf method
###
def push_to_cf(domain:str, ipaddr, zone_id, domain_id):

    try:
        True
    except:
        True



###
# Make sure IP is not Local Link
###
try:
    if ipv4.is_global:
        pre_check(ddns_domain['v4'], ipv4, 'A')
    if ipv6.is_global:
        pre_check(ddns_domain['v6'], ipv6, 'AAAA')
except:
    print('You Have NO Global IP Address')
    exit(44)