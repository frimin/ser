#!/usr/bin/env bash

if [[ ! -d ~/.ser/bin ]]; then
    mkdir -p ~/.ser/bin || exit 255
fi

echo "Download to: ~/.ser/bin/ser ..."

curl -s -L https://raw.githubusercontent.com/frimin/ser/master/ser -o ~/.ser/bin/ser || exit 255 

chmod u+rx ~/.ser/bin/ser || exit 255

echo 'Remember add to your profile: export PATH="$HOME/.ser/bin:$PATH"'

echo 'Done !!'
