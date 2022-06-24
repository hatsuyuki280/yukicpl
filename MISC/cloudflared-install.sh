#!/bin/bash
wget https://github.com/cloudflare/cloudflared/releases/download/2021.7.0/cloudflared-linux-arm64
chmod +x ./cloudflared-linux-arm64
mkdir -p /yukicpl/opt/cloudflare
mv ./cloudflared-linux-arm64 /yukicpl/opt/cloudflare/cloudflared
echo 'export PATH=$PATH:/yukicpl/opt/cloudflare' >> ~/.bashrc
. .bashrc

cloudflared tunnel login
cloudflared tunnel create 
cat >> ~/.cloudflared/config.yml << EOF
tunnel: $(cloudflared tunnel list --name ora-free-amd-01 -o yaml | grep id | sed 's/ /\n/g' | tail -1)
credentials-file: /root/.cloudflared/$(cloudflared tunnel list --name ora-free-amd-01 -o yaml | grep id | sed 's/ /\n/g' | tail -1).json

ingress:
  - hostname: n1-node2.moeyuki.works
    service: ssh://localhost:22
  - service: http_status:404
  # Catch-all rule, which responds with 404 if traffic doesn't match any of
  # the earlier rules
EOF
cloudflared service install

systemctl enable cloudflared --now
systemctl status cloudflared