while getopts "h-:" opt; do
  case $opt in
    -)
      echo $OPTARG $2
      case $OPTARG in
        language)
          case $2 in
            zh_CN)
              echo "Chinese"
              ;;
            *)
              echo "Invalid Language"
              exit 1
              ;;
          esac
          ;;
      esac
      ;;
  esac
done
