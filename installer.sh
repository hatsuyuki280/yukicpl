#!/bin/bash

# This script is used to install the application and its dependencies

pre_check() {
    # Check if the user is root
    if [ "$(id -u)" != "0" ]; then
        gettext "Please run this script as root."
        echo "This script must be run as root" 1>&2
        exit 1
    fi
    # Check system distribution
    if [ -f /etc/debian_version ]; then
        DISTRO="Debian"
    elif [ -f /etc/os-release ]; then
        DISTRO="Ubuntu"
    else 
        echo "This script only supports Debian and Ubuntu, will exit with err code 2." 1>&2
        exit 2
    fi
    # Check package manager
    if [ -f /usr/bin/apt ]; then
        PKG_MGR="apt"
    elif [ -f /usr/bin/yum ]; then
        PKG_MGR="yum"
    else
        echo "This script only supports apt and yum" 1>&2
        exit 1
    fi
    # Check Package Manager and Update
    if [ "$PKG_MGR" = "apt" ]; then
        apt update > /dev/null 2>>/var/log/yukicpl_spm.err
    elif [ "$PKG_MGR" = "yum" ]; then
        echo "yum is not supported yet" | tee -a /var/log/yukicpl_installer.err 1>&2
        # yum update > /dev/null 2>>/var/log/yukicpl_spm.err
    fi
    # Check dependencies
    if ! command -v whiptail >/dev/null 2>&1; then
        echo "whiptail is not installed, will running at text mode" | tee -a /var/log/yukicpl_installer.err 1>&2
    fi
    echo "TUI is not ready yet, please wait release version." | tee -a /var/log/yukicpl_installer.err 1>&2
    if ! command -v msgfmt >/dev/null 2>&1; then
        echo "gettext is not installed, will install it later" | tee -a /var/log/yukicpl_installer.err 1>&2
        install -p "gettext"
    fi
}

install() (
    while getopts "p:" opt; do
        case $opt in
            p)
                $PKG_MGR install -y $OPTARG >/dev/null 2>>/var/log/yukicpl_spm.err
                ;;
        esac
    done
)

# PrintArgumentHelp()(
#     echo ""
#     echo "$LangArgumentHelpDescription"
# )

# prepare arguments
while getopts ":ht" opt; do
  case $opt in
    h)
      PrintArgumentHelp && quit
      exit 0
      ;;
    t)
      TestMode=1
      echo "$LangUsingTestMode"
    ;;
    :)
      echo "$LangOption -$OPTARG $LangRequires$LangArgumentGive" 
      exit 1
      ;;
    ?)
      echo "$LangInvalidArgumentGived"
      ;;
  esac
done
