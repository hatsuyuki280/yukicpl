#!/bin/bash
[ "${#@}" -eq 0 ] && ("$0" -h; exit 0)
declare -a args

LogSomeThings(){
  echo "$@" >> "${YUKICPL_LOG_FILE}"
}

ShowVersion(){
  echo "yukicpl Version: ${YUKICPL_VERSION}"
}

ShowConfig(){
  echo "Config File: ${YUKICPL_CONFIG_FILE}"
  grep -Ev '^#|^$' "${YUKICPL_CONFIG_FILE}" | column -t -s "="
}

main(){
  $COMMAND "$@"
}

while getopts "hc:a:" opt ; do
  case $opt in
    h)
      echo 'This is Help Message.
      -h: Show this help message.
      -c: select command to run.
      -a: give arguments to command.'
      exit 0
      ;;
    c)
      COMMAND="$OPTARG"
      ;;
    a)
      args=("${OPTARG//,/ }")
      ;;
    *)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

main "${args[@]}"