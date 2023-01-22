#!/bin/bash
## main Version: 0.0.1
# shellcheck source=/dev/null ## Disable the warning of missing source
# shellcheck disable=SC2015 ## Disable the warning of a && b || c
# shellcheck disable=SC2016 ## Disable the warning of variable in single quote
[ $UID -ne 0 ] && {
  echo "You are not root, Trying to run with sudo..."
  test -a /usr/bin/sudo || sudo() (su -c "$@")
  sudo "$0" "$@"
  exit $?
}

###
# Global Variables
###
declare -A YUKICPL_ENV
YUKICPL_ENV[ConfigFile]="/etc/yukicpl/config.conf"
YUKICPL_ENV[ConfigDir]="$(dirname "${YUKICPL_ENV[ConfigFile]}")"
_os_id="$(grep "^ID_LIKE" /etc/os-release | cut -d "=" -f 2)"
[ -z "$_os_id" ] && _os_id="$(grep "^ID" /etc/os-release | cut -d "=" -f 2)"


# path to Extension Directory
ExtensionDir="/opt/yukicpl/extensions"

###
# 传入参数处理
###
while getopts "hto:c:D:" opt; do
  case $opt in
  h)
    echo "Usage: $0 [-ht] [-o option1,option2...] [-c configfile] [-D [logpath]]" >&2
    echo "  -h  Show this help message and exit." >&2
    echo "  -t  Run in text mode." >&2
    echo "  -o  Set options. Available options:" >&2
    echo "      debug: Enable debug mode." >&2
    echo "      basic: Run in basic mode." >&2
    echo "  -c  Set config file path." >&2
    echo "  -D  Enable debug mode and set log file path." >&2
    echo "      If no log file path is set, will use /tmp/yukicpl.log" >&2
    echo "      If the log file path is a directory, will use <path>/yukicpl.log" >&2
    echo "      If the log file path is a file, will use it directly." >&2
    echo -e "\n\n\nfor more information, please visit: https://yukicpl.moeyuki.works" >&2
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
    IFS=',' read -r -a options <<<"$OPTARG"
    for i in "${options[@]}"; do
      case $i in
      debug) DebugMode=1 ;;
      basic) basicMode=1 ;;
      *)
        printf '%s\n' "$(T_ 'Unknown option: ')$i" | tee -a "$Log"
        exit 1
        ;;
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
  \?)
    echo "Invalid option: -$opt" >&2
    exit 1
    ;;
  esac
done

###
# Pre-check And Prepare required functions
###
# check if gettext is installed
[ -f /usr/bin/gettext ] && { ##
  alias T_='gettext "yukicpl"'
  #[ DebugMode -eq 1 ] && printf '%s\n' "$(T_ 'gettext is installed, will use it to translate the text')" >&2
  } || {
  #[ DebugMode -eq 1 ] && echo "gettext is not installed now. Using Default Language." >&2
  alias T_='echo'
}

[ -f "${YUKICPL_ENV[ConfigFile]}" ] && source "${YUKICPL_ENV[ConfigFile]}" || printf '%s\n' "$(T_ 'Config file not found, will run init now.')" >&2
initMode=1
[ -z "$(ls -A \"$ExtensionDir/enabled\")" ] && printf '%s\n' "$(T_ 'No extension enabled, will run in basic mode.')"
basicMode=1

alias install="/usr/local/lib/yukicpl/installer.sh"

GetExtensionList() {
  [ "${#@}" -eq 0 ] && lists=(enabled) || lists=("$@")
  declare -A extensions
  for list in "${lists[@]}"; do
    [ -d "$ExtensionDir/$list" ] || {
      [ "$DebugMode" -eq 1 ] && printf '%s\n' "$(T_ 'Extension directory "$list" not found, will skip this extension.')" >&2
      continue
    }
    for extension in "$ExtensionDir/$list"/*; do
      [ -d "$extension" ] || continue
      [ -f "$extension/metadata.json" ] || {
        printf '%s\n' "$(T_ 'Metadata file not found, will skip this extension.')"
        continue
      }
      _supported_dist=("$(jq -r '.SupportedDist[]' "$1")")
      [[ "${_supported_dist[*]}" =~ [[:Space:]]${_os_id}[[:Space:]] ]] || {
        printf '%s\n' "$(T_ 'This extension is not supported on your system, will skip this extension.')"
        continue
      }
      _extension_name="$(jq -r '.Name' "$extension/metadata.json")"
      extensions["$_extension_name"]="$list"
      unset _supported_dist _extension_name
    done
  done
  declare -p extensions
}


ParserExtensionMetadata() {

  [ -f "$1" ] || {
    printf '%s\n' "$(T_ 'Metadata file not found, will skip this extension.')"
    return 1
  }
  ## get metadata used keys
  _keys=("$(jq -r 'Keys[]' "$1")")

  ## check if the platform is supported
  
}

TitleBuilder() {
  textLength=${#1}
  windowWidth=$(tput cols)
  [ "$windowWidth" -gt 72 ] && windowWidth=72
  printf "%*s\n" $(((windowWidth - 2 + textLength) / 2)) "-$1-"
}

SwitchToSelectMode() (
  PS3="$(T_ 'your choice:')"

  select option; do
    [ "$DebugMode" -eq 1 ] && printf '%s\n' "$(T_ 'Selected option: ')$option"
    echo "$REPLY"
    break
  done
)

MutliSelectMode() (
  selected_id=()
  num_of_options=${#@}
  options=("$@")
  while [ "${selected_id[-1]}" -le "$(num_of_options)" ] || [ "${#selected_id}" -eq 0 ]; do
    temp_options=("${options[@]}")
    for i in $(seq 0 "$((num_of_options-1))"); do
      temp=${temp_options["$i"]}
      temp_options["$i"]="[_]$temp"
      for j in "${selected_id[@]}"; do
        [ "$i" -eq "$j" ] && {
          temp_options["$i"]="[*]$temp"
          break
        }
      done
    done
    selected_id+=("$(SwitchToSelectMode "${temp_options[@]}" "Done")")
  done
  unset "selected_id[-1]"
  echo "${selected_id[@]}"
)

SelectLanguage() (
  clear
  TitleBuilder "$(T_ 'Select Language')"
  printf '%s\n' "$(T_ 'We will help you to configure yukicpl now.')"
  printf '%s\n' "$(T_ 'At first, we need to know your prefered language.')"
  printf '%s\n' "$(T_ 'Please make choice below:')"
  usable_languages=()
  [ "$(grep -m 1 "offline_mode:" "${YUKICPL_ENV[ConfigFile]}" | cut -d ":" -f 2)" = "No" ]
  choice="$(SwitchToSelectMode "${usable_languages[@]}")"
  case $choice in
  1) LANG="en_US.UTF-8" ;;
  2) LANG="zh_CN.UTF-8" ;;
  3) LANG="ja_JP.UTF-8" ;;
  esac
  unset choice
  [ -f "/usr/share/locale/$LANG/LC_MESSAGES/yukicpl.mo" ] && {
    printf '%s\n' "$(T_ 'Try to using the selected language now.')"
    echo "LANG=$LANG" >>"${YUKICPL_ENV[ConfigFile]}"
    clear
  } || {
    clear
    TitleBuilder "$(T_ 'Welcome to yukicpl!')"
    printf '%s\n' "$(T_ 'The selected Language is not installed, Try to install it now?')"
    choice=$(SwitchToSelectMode "$(T_ 'Yes')" "$(T_ 'No')")
    case $choice in
    1)
      printf '%s\n' "$(T_ 'Try to get translation file from repository now.')"
      if wget -q -O "/usr/share/locale/$LANG/LC_MESSAGES/yukicpl.mo" "https://yukicpl.moeyuki.works/dist/i18n/$LANG/yukicpl.mo"; then
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
_init() (
  clear
  TitleBuilder "$(T_ 'Welcome to yukicpl!')"
  printf '%s\n' "$(T_ 'We will help you to configure yukicpl now.')"
  printf '%s\n' "$(T_ 'We are checking some basic settings now.')"
  [ -d "${YUKICPL_ENV[ConfigDir]}" ] || {
    printf '%s\n' "$(T_ 'Config directory not found, will create one now.')"
    mkdir -p "${YUKICPL_ENV[ConfigDir]}"
  }
  [ -f "${YUKICPL_ENV[ConfigFile]}" ] || {
    printf '%s\n' "$(T_ 'Config file not found, will create one now.')"
    touch "${YUKICPL_ENV[ConfigFile]}"
  }
)

_show_plugins() (
  clear
  TitleBuilder "$(T_ 'HTTP & File Sharing')"
  printf '%s\n' "$(T_ 'Please make choice below:')"
  choice="$(SwitchToSelectMode "$(T_ 'HTTP Server')" "$(T_ 'File Sharing')" "$(T_ 'Back')")"
  case $choice in
  1)
    _http_server
    ;;
  2)
    _file_sharing
    ;;
  3) _main_menu ;;
  esac
  unset choice
)


_main_menu() (
  clear
  TitleBuilder "$(T_ 'Main Menu')"
  printf '%s\n' "$(T_ 'Please make choice below:')"
  choice="$(SwitchToSelectMode "$(T_ 'HTTP & File Sharing')" "$(T_ 'System Management')" "$(T_ 'Yukicpl Settings')" "$(T_ 'Exit')")"
  case $choice in
  1)
    _show_plugins
    ;;
  2)
    _system_management
    ;;
  3)
    _yukicpl_settings
    ;;
  4) exit 0 ;;
  esac
  unset choice
)

###
# Main Menu
###
main() (
  TitleBuilder "$(T_ 'YukiCPL')"
  ## Load Extensions
  [ "$basicMode" -eq 0 ] && {
    true
  }
  _main_menu
  case $? in
  0) exit 0 ;;
  1) _main_menu ;;
  esac
)

###
# Exec Main Method
###
[ "$initMode" -eq 1 ] && _init
main