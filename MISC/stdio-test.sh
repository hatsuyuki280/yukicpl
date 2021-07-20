#!/bin/bash
echo " $@"
echo $@ | grep -q -- "--full" && easy=0
echo $@ | grep -q -- "--ja" && lang="ja"
echo $@ | grep -q -- "--en" && lang="en"

echo $lang

[ $easy -eq 0 ] && echo "will full install"