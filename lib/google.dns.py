import requests

url_base = 'https://dns.google/resolve'
record_map = {
    "A": 1,
    "NS": 2,
    "CNAME": 5,
    "PTR": 12,
    "MX": 15,
    "TXT": 16,
    "AAAA": 28,
    "SRV": 33,
    "CERT": 37,
    "SSHFP": 44,
    "IPSECKEY": 45,
    "TLSA": 52,
    "OPENPGPKEY": 61,
    "HTTPS": 65,
    "SPF": 99,
    "*": 255,
    "URI": 256,
    "CAA": 257
}