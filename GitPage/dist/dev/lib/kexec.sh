#!/bin/bash

# main Version: 0.0.1

[ $UID -ne 0 ] && {
  echo "You are not root, Trying to run with sudo..." 
  test -a /usr/bin/sudo && {
    sudo -i
  }
  || sudo()( su -c "$@";)

}

install(){
  [ "$(cat /etc/os-release | grep "ID_LIKE" | cut -d "=" -f 2)" = "debian" ] && {
    apt update && sudo apt -y full-upgrade
    apt install -y kexec-tools
    mv /etc/systemd/system/kexec.service /etc/systemd/system/kexec.service.bak
    cat >> /etc/systemd/system/kexec.service << EOF
[Unit]
Description=Kexec
After=network.target

EOF
  } || {
    echo 'The system is not Debian based, Using this script may cause damage to your system.
if you really want to continue, please install it manually.'
    exit 1
  }



}
