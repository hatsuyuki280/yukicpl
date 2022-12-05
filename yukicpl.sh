#!/bin/bash
## main Version: 0.0.1

###
# Global Variables
###
# shellcheck disable=SC2015 ## Disable the warning of [ $var ] && echo "true" || echo "false"
ConfigFile="/etc/yukicpl/config.conf"

[ $UID -ne 0 ] && {
  echo "You are not root, Trying to run with sudo..." 
  test -a /usr/bin/sudo || sudo()( su -c "$@";)
  sudo "$0" "$@"
  exit $?
}

###
# Default Settings
# You can also change these settings in config file.
# or just give them as arguments to the script.
# You can find the config file at path: $ConfigFile.
# * This value is defined in the first line of this script.
# * Usually it's /etc/yukicpl/config.conf, but you can change it (Not recommended).
# for all usage, see the help message.
# if multiple values are given, at config file, the last one will be used.
# if it at command line, the first one will be used.
# if it at both, the one at command line will be used.
###
# path to Extension Directory
ExtensionDir="/opt/yukicpl/extensions"

###
# Pre-check And Prepare required functions
###
# check if gettext is installed
[ -f /usr/bin/gettext ] && {  ## 
  alias T_='gettext "yukicpl"'
  #[ DebugMode -eq 1 ] && printf '%s\n' "$(T_ 'gettext is installed, will use it to translate the text')" >&2
} || {
  #[ DebugMode -eq 1 ] && echo "gettext is not installed now. Using Default Language." >&2
  alias T_='echo'
}
# shellcheck source=/dev/null
[ -f "$ConfigFile" ] && source "$ConfigFile" || printf '%s\n' "$(T_ 'Config file not found, will run init now.')" >&2 ; initMode=1
[ -z "$(ls -A \"$ExtensionDir/enabled\")" ] && printf '%s\n' "$(T_ 'No extension enabled, will run in basic mode.')"; basicMode=1

#[ $DebugMode -eq 1 ] printf '%s\n' "$(T_ 'Ready to use, Press any key to continue...')" && read -n1


###
# Define Internal Functions
###
# PrintArgumentHelp()(
#   echo "Usage: yukicpl [OPTION]..."
#   echo "  -h, --help      Print this help message."
#   echo "  -t, --text      Run in text mode."
#   echo "      --language  Set language."
# )

GetExtensionList(){
  declare -A extensions
  for ext in "$ExtensionDir"/enabled/*; do
    grep -m 1 "SupportedDist" "$ExtensionDir/enabled/$ext/meta.json" | grep -q "$(grep "ID_LIKE" /etc/os-release | cut -d "=" -f 2)" && {
      extensions["$ext"]=$(grep -m 1 "ShortDescription" "$ExtensionDir/enabled/$ext" | cut -d "=" -f 2)
    } || {
      printf '%s\n' "$(T_ "Extension $ext is not supported on this system, will skip it.")"
    }
  done
  declare -p extensions
}

GetExtensionInfo(){
  declare -A ExtensionInfo
  ExtensionInfo["Name"]="$(grep -m 1 "Name:" "$ExtensionDir/enabled/$1/" | cut -d ":" -f 2)"
  ExtensionInfo["Version"]="$(grep -m 1 "Version:" "$ExtensionDir/enabled/$1" | cut -d ":" -f 2)"
  ExtensionInfo["Description"]="$(grep -m 1 "Description:" "$ExtensionDir/enabled/$1" | cut -d ":" -f 2)"
  ExtensionInfo["Author"]="$(grep -m 1 "Author:" "$ExtensionDir/enabled/$1" | cut -d ":" -f 2)"
  ExtensionInfo["Functions"]="$(grep -m 1 "Functions:" "$ExtensionDir/enabled/$1" | cut -d ":" -f 2 | sed 's/,/ /g')"
  ExtensionInfo["License"]="$(grep -m 1 "License:" "$ExtensionDir/enabled/$1" | cut -d ":" -f 2)"
  declare -p ExtensionInfo
}

TitleBuilder(){
  textLength=${#1}
  windowWidth=$(tput cols)
  [ "$windowWidth" -gt 72 ] && windowWidth=72
  printf "%*s\n" $(( (windowWidth-2 + textLength) / 2)) "-$1-"
}

SwitchToSelectMode()(
  PS3="$(T_ 'your choice:')"

  select option ;
  do
    [ "$DebugMode" -eq 1 ] && printf '%s\n' "$(T_ 'Selected option: ')$option"
    echo "$REPLY"
    break
  done
)

MutliSelectMode()(
  selected_id=()
  num_of_options=${#@}
  options=("$@")
  while [ "${selected_id[-1]}" -ne "$num_of_options" ] || [ "${#selected_id}" -eq 0 ]; do
    for i in $(seq 1 "$num_of_options"); do
      temp=${options["$i"]}
      options["$i"]="[_]$temp"
      for j in "${selected_id[@]}"; do
        [ "$i" -eq "$j" ] && {
          options["$i"]="[*]$temp"
          break
        }
      done
    done
    selected_id+=("$(SwitchToSelectMode "${options[@]}" "Done")")
  done
  unset "selected_id[-1]"
  echo "${selected_id[@]}"
)

SelectLanguage()(
  clear
  TitleBuilder "$(T_ 'Select Language')"
  printf '%s\n' "$(T_ 'We will help you to configure yukicpl now.')"
  printf '%s\n' "$(T_ 'At first, we need to know your prefered language.')"
  printf '%s\n' "$(T_ 'Please make choice below:')"
  usable_languages=()
  [ "$(grep -m 1 "offline_mode:" "$ConfigFile" | cut -d ":" -f 2)" = "No" ] 
  choice="$(SwitchToSelectMode "${usable_languages[@]}")"
  case $choice in
    1) LANG="en_US.UTF-8";;
    2) LANG="zh_CN.UTF-8";;
    3) LANG="ja_JP.UTF-8";;
  esac
  unset choice
  [ -f /usr/share/locale/$LANG/LC_MESSAGES/yukicpl.mo ] && {
    printf '%s\n' "$(T_ 'Try to using the selected language now.')"
    echo "LANG=$LANG" >> "$ConfigFile"
    clear
  } || {
    clear
    TitleBuilder "$(T_ 'Welcome to yukicpl!')"
    printf '%s\n' "$(T_ 'The selected Language is not installed, Try to install it now?')"
    choice=$(SwitchToSelectMode "$(T_ 'Yes')" "$(T_ 'No')")
    case $choice in
      1) 
        printf '%s\n' "$(T_ 'Try to get translation file from repository now.')"
        if wget -q -O "/usr/share/locale/$LANG/LC_MESSAGES/yukicpl.mo" "https://yukicpl.moeyuki.works/dist/i18n/$LANG/yukicpl.mo" ; then
          printf '%s\n' "$(T_ 'Translation file downloaded successfully.')"
        else
          printf '%s\n' "$(T_ 'Failed to download translation file, please try again later.')"
          exit 1
        fi
        ;;
      2) printf '%s\n' "$(T_ 'Will use default language now.')" ;;
    esac
    unset choice
  }
)

###
# Init Menu
###
_init()(
  clear
  TitleBuilder "$(T_ 'Welcome to yukicpl!')"
  printf '%s\n' "$(T_ 'Looks good, Next we need to know what features you want to use.')"
)

###
# Main Menu
###
main()(
  echo ""
  ## Load Extensions
  [ "$basicMode" -eq 0 ] && {
    eval "$(GetExtensionList)"
    [ "$DebugMode" -eq 1 ] && printf '%s\n' "$(T_ 'Extensions loaded.')" | tee -a "$Log" ; declare -p extensions | tee -a "$Log"
  }

)


###
# 传入参数处理
###
while getopts "hto:c:D:-:" opt; do
  case $opt in
    h)
      PrintArgumentHelp
      exit 0
      ;;
    t)
      # textMode=1
      true
      ;;
    c)
      ConfigFile="$OPTARG"
      ;;
    o)
      options=("${OPTARG//,/ }")
      for i in "${options[@]}"; do
        case $i in
          debug) DebugMode=1;;
          basic) basicMode=1;;
          *) printf '%s\n' "$(T_ 'Unknown option: ')$i" | tee -a "$Log"; exit 1;;
        esac
      done
      ;;
    D)
      DebugMode=1
      [ -z "$OPTARG" ] && {
        Log="/tmp/yukicpl.log"
      } || {
        [ -d "$OPTARG" ] && {
          Log="$OPTARG/yukicpl.log"
        } || {
          [ -f "$OPTARG" ] && {
            Log="$OPTARG"
          } || {
            Log="/tmp/yukicpl.log"
          }
        }
      }
      ;;
    -)
      case $OPTARG in
        help)
          PrintArgumentHelp
          exit 0
          ;;
        text)
          # textMode=1
          true
          ;;
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
[ "$initMode" -eq 1 ] && _init
main