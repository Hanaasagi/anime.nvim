#!/bin/bash

set -e
RESULT="/tmp/anime-supported"

# sleep 12

stty -echo
IFS=";?c" read -a REPLY -s -t 2 -d "c" -p $'\e[c' >&2
stty echo

for code in "${REPLY[@]}"; do
if [[ $code == "4" ]]; then
    hassixel=yup
    break
fi
done


if [[ "$TERM" == yaft* ]]; then hassixel=yeah; fi

if [[ -z "$hassixel" && -z "$LSIX_FORCE_SIXEL_SUPPORT" ]]; then
    echo 1 > $RESULT
    exit 1
fi

echo 0 > $RESULT
exit 0
