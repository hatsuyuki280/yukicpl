#!/bin/bash
# shellcheck disable=SC2016
[ -f /usr/bin/openssl ] || {
    echo 'openssl is not installed. please install it first.'
    exit 1
}
[ -f ./ca.key ] || {
    echo 'ca.key is not found. generating...'
    openssl req -newkey rsa:2048 -days 36500 -x509 -nodes -keyout ca.key -out ca.crt -subj '/CN=CA for yukicpl' >/dev/null 2>&1
}
[ -f ./ca.conf ] || {
    echo 'ca.conf is not found. generating...'
    cat > ca.conf << EOF
[ ca ]
default_ca = this

[ this ]
new_certs_dir = .
certificate = ca.pem
database = ./index
private_key = ca.key
serial = ./serial
default_days = 36500
default_md = default
policy = policy_anything

[ policy_anything ]
countryName             = optional
stateOrProvinceName     = optional
localityName            = optional
organizationName        = optional
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = optional
EOF
}
[ -f ./index ] || touch ./index
[ -f ./serial ] || echo '01' > ./serial
openssl req -newkey rsa:2048 -nodes -out "$(hostname).csr" -keyout "$(hostname).key" -subj "/CN=$(hostname)/"
openssl ca -batch -config ca.conf -notext -in "$(hostname).csr" -out "$(hostname).crt" >/dev/null 2>&1
rm "$(hostname).csr"




echo 'Please run this 2 commands on your client machine, and paste the output here:'
echo 'openssl req -newkey rsa:2048 -nodes -keyout client.key -out - -subj "/CN=$(hostname)" '
read -r -p 'Paste the output here: ' clientcsr
echo -en 'processing...\r'
openssl ca -batch -config ca.conf -notext -in <(echo "$clientcsr") -out client.crt >/dev/null 2>&1
echo 'done. here is the client certificate:'
cat client.crt
rm client.crt
echo 'please save your client cert to your client machine.'
echo 'if you need ca certificate, you can find it in ca.crt'



