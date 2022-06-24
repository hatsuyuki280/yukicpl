#!/bin/bash
test -a /usr/bin/sudo || sudo()( su -c "$@";)

###
# AdvanceSetting
###
ExFileIn="/usr/local/lib/yukicpl/"
lang=$LANG
echo $@ | grep -q -- "--ja_JP.UTF-8" && lang="ja_JP.UTF-8"
echo $@ | grep -q -- "--C.UTF-8" && lang="C.UTF-8"
echo $@ | grep -q -- "--zh_CN.UTF-8" && lang="zh_CN.UTF-8"
echo $@ | grep -q -- "--ja" && lang="ja_JP.UTF-8"
echo $@ | grep -q -- "--en" && lang="C.UTF-8"
echo $@ | grep -q -- "--zh" && lang="zh_CN.UTF-8"

ConfFileIn="/etc/yukicpl/yukicpl.conf"
TraslateFile="/etc/yukicpl/yukicpl.$lang"
DistChannel="dev"

[ -f "$TraslateFile" ] && {
    source "$TraslateFile"
  } || {
    echo "Translate File Not Found.\nDownloading...";
    lang="C.UTF-8";
    wget "https://yukicpl.moeyuki.tech/dist/$DistChannel/i18n/yukicpl.$lang"\
    -O "$TraslateFile";
}

###
# pre-test and set env variables
###
export NEWT_COLORS='window=,white;border=black,white;textbox=black,white;button=white,cyan;title=black,white;shadow=,gray'


Init()(
    whiptail --title "$LangTitle" --msgbox "$LangInitWelcomeMsg" 10 40 --ok-button "$LangContinueButton"
    whiptail --title "$LangTitle" --yesno "$LangReadBeforeInitMsg" 25 55 --scrolltext --no-button "$LangNoButton" --yes-button "$LangContinueButton" || { echo "$LangPleaseAcceptItBeforeUse" ; exit 1; }
    functionlist="lnmp $LangFunctionListLNMP 0\
                  ok-www $LangFunctionListOneKeyWWW 0\
                  cfd $LangFunctionListCloudflared 0\
                  sevpn $LangFunctionListSoftEtherVPN 0\
                  sm-tools $LangFunctionListSystemManagermentTools 0\
                "
    selectedFunction="$(whiptail --title "$LangTitle" --checklist "$LangFunctionSelectScreenMsg" 25 50 17 $functionlist 3>&1 1>&2 2>&3)"
    # 3>&1 1>&2 2>&3
)

test -e "$ConfFileIn" || {
    echo "$LangCanNotFound$LangConfigureFiles\n$LangStartToPreConfig"
    sleep 2
    Init
}
source "$ConfFileIn"


main()(
echo 'Writing now'
)

PrintArgumentHelp()(
    echo "$LangArgumentHelpTitle"
    echo "$LangArgumentHelpDescription"
)

###
# 传入参数处理
###
while getopts ":ht" opt; do
  case $opt in
    h)
      PrintArgumentHelp && quit
      exit 0
      ;;
    t)
      TestMode=1
      echo "$LangUsingTestMode"
      sleep 2
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
echo $@ | grep -q -- "--full-install" && full=1

###
# Exec Main Method
###
main