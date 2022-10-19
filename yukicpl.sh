#!/bin/bash
## main Version: 0.0.1

[ $UID -ne 0 ] && {
  echo "You are not root, Trying to run with sudo..." 
  test -a /usr/bin/sudo || sudo()( su -c "$@";)

###
# AdvanceSettings
#
# Path to Config File
ConfigFile="/etc/yukicpl.conf"
# path to Extension Directory
ExtensionDir="/opt/yukicpl/extensions"

###
# Pre-check And Prepare required functions
###
# check if gettext is installed
[ -f /usr/bin/gettext ] && {  ## 
  alias T_='gettext "yukicpl"'
  #[ DebugMode -eq 1 ] && echo "$(T_ 'gettext is installed, will use it to translate the text')" >&2
} || {
  #[ DebugMode -eq 1 ] && echo "gettext is not installed now. Using Default Language." >&2
  alias T_='echo'
}
[ -f /etc/yukicpl.conf ] && source "$ConfigFile" || echo "$(T_ 'Config file not found, will run init now.')" >&2 ; initMode=1
[ -z "$(ls -A "$ExtensionDir")" ] && echo "$(T_ 'Extension directory is empty, Please select an extension later.')" && extensionSelectMode=1
#[ -f /usr/bin/whiptail ] || echo "$(T_ 'whiptail is not installed, will run in text mode.')"; textMode=1


#[ $DebugMode -eq 1 ] echo "$(T_ 'Ready to use, Press any key to continue...')" && read -n1


###
# Define Internal Functions
###
# PrintArgumentHelp()(
#   echo "Usage: yukicpl [OPTION]..."
#   echo "  -h, --help      Print this help message."
#   echo "  -t, --text      Run in text mode."
#   echo "      --language  Set language."
# )

TitleBuilder(){
  textLength=${#1}
  windowWidth=$(tput cols)
  [ $windowWidth -gt 72 ] && windowWidth=72
  printf "%*s\n" $(( (windowWidth-2 + textLength) / 2)) "-$1-"
}

SwitchToSelectMode()(
  PS3="$(T_ 'your choice:')"
  select option in $@
  do
    [[ $REPLY =~ ^[0-9]+$ ]] && {
      [ $REPLY -le ${#@} ] && {
        # [ $DebugMode -eq 1 ] && echo "$(T_ 'Selected option: ')$option"
        echo $REPLY
        break
      } || echo "$(T_ 'more than iterm, please try again.')" >&2 && continue
    } || echo "$(T_ 'not a number, please try again.')" >&2 && continue
  done
)

MutliSelectMode()(
  PS3="$(T_ 'your choice:')"
  select option in $@
  do
    [ -z "$REPLY" ] && echo "$(T_ 'Invalid option, please try again.')" >&2 && continue
    [[ $REPLY =~ ^[0-9]+$ ]] && [ $REPLY -le ${#option[@]} ] && {
      # [ $DebugMode -eq 1 ] && echo "$(T_ 'Selected option: ')$option"
      echo $REPLY
      break
    } || echo "$(T_ 'Invalid option, please try again.')" >&2 && continue
  done
)

###
# Init Menu
###
_init()(
  clear
  TitleBuilder "$(T_ 'Welcome to yukicpl!')"
  echo "$(T_ 'We will help you to configure yukicpl now.')"
  echo "$(T_ 'At first, we need to know your prefered language.')"
  echo "$(T_ 'Please make choice below:')"
  choice="$(SwitchToSelectMode "$(T_ 'English') $(T_ 'Chinese') $(T_ 'Japanese')")"
  case $choice in
    1) LANG="en_US.UTF-8";;
    2) LANG="zh_CN.UTF-8";;
    3) LANG="ja_JP.UTF-8";;
  esac
  unset choice
  echo "LANG=$LANG" >> "$ConfigFile"
  [ -f /usr/share/locale/$LANG/LC_MESSAGES/yukicpl.mo ] && {
    echo "$(T_ 'Try to using the selected language now.')"
  } || {
    echo "$(T_ 'The selected Language is not installed, Try to install it now?')"
    choice="$(SwitchToSelectMode "$(T_ 'Yes') $(T_ 'No')")"
    case $choice in
      1) 
        echo "$(T_ 'Try to get translation file from repository now.')"
        wget -q -O /usr/share/locale/$LANG/LC_MESSAGES/yukicpl.mo https://yukicpl.moeyuki.works/dist/i18n/$LANG/yukicpl.mo
        [ $? -eq 0 ] && {
          echo "$(T_ 'Translation file downloaded successfully.')"
        } || {
          echo "$(T_ 'Failed to download translation file, please try again later.')"
          exit 1
        }
        [ $? -eq 0 ] && echo "$(T_ 'Translation file downloaded successfully.')" || echo "$(T_ 'Failed to download translation file.')"
        apt-get install language-pack-$LANG
        ;;
      2) echo "$(T_ 'Will use default language now.')" ;;
    esac
  }
  echo "$(T_ 'Looks good, Next we need to know what features you want to use.')"
  
)

[ $InitMode -eq 1 ] && _init


###
# Main Menu
###
main()(
  echo ""
)


###
# 传入参数处理
###
while getopts "ht-:" opt; do
  case $opt in
    h)
      PrintArgumentHelp
      exit 0
      ;;
    t)
      textMode=1
      ;;
    -)
      case $OPTARG in
        help)
          PrintArgumentHelp
          exit 0
          ;;
        text)
          textMode=1
          ;;
        language)
          case $2 in
            zh_CN)
              lang="zh_CN"
              ;;
            en_US)
              lang="en_US"
              ;;
            ja_JP)
              lang="ja_JP"
              ;;
            *)
              echo "Invalid Language"
              exit 1
              ;;
          esac
        *)
          echo "Invalid option: --$OPTARG" >&2
          exit 1
          ;;
      esac
      ;;
    \?)
      echo "Invalid option: -$opt" >&2
      exit 1
      ;;
  esac
done


###
# Exec Main Method
###
main