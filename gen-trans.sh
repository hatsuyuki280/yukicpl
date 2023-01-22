#!/bin/bash

## This file will be used to generate and update the translation file
## in most cases, you don't need to modify or run this file
## this file will automatically run by Github Actions when Pushing to the repository.

## basicly, this file will running at ubuntu-latest

## check if the user is root
if [ "$(id -u)" != "0" ]; then
    echo "Please run this script as root."
    echo "This script must be run as root" 1>&2
    exit 1
fi

# prepare arguments
while getopts "d:" opt; do
  case $opt in
    d)
      cd "$OPTARG" || {
        echo "Can not change directory to $OPTARG"
        exit 1
      }
      ;;
    *)
      echo "Usage: $0 [-d <directory>] [-t]"
      exit 1
  esac
done

# install build dependencies
command apt update && apt install -y gettext

# generate translation file
if [ $"pwd" = "/home/runner/work/yukicpl" ]; then
  echo "Generating translation file..."
  xgettext -o yukicpl.pot -L Shell -kL_ --from-code=UTF-8 --package-name=yukicpl --package-version="$(grep -Eom1 '([0-9]\.*){3}' yukicpl.sh)" yukicpl.sh
  msgmerge -U zh_CN.po yukicpl.pot
  msgfmt -o zh_CN.mo zh_CN.po
  echo "Done."
else
  echo "Can not find the project directory"
  exit 1
fi