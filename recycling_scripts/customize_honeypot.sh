#!/bin/bash

# This script updates the language on the container, generates honey,
# and copies the honey onto the machine.

if [[ $# -ne 2 ]]; then
  echo "Provide 2 shells arguments for the container name, and language (english, spanish, russian, chinese)."
  exit 1
fi

container_name = $1
language = $2

# Generate honey for respective language. Will save to a folder named "generated"
python3 ../honeymaker.py --language $language

# Add functionality to copy generated files/folders from "generated" folder to the container.
#### < TO DO > ####

# rm -rf generated

case $language in
  "english")
    # No need to change language settings for English.
    ;;
  "spanish")
    sudo lxc-attach -n "$container_name" -- bash -c 'sudo apt-get install language-pack-es'
    sudo lxc-attach -n "$container_name" -- bash -c 'sudo update-locale LANG=es_ES.UTF-8'
    ;;
  "russian")
    sudo lxc-attach -n "$container_name" -- bash -c 'sudo apt-get install language-pack-ru'
    sudo lxc-attach -n "$container_name" -- bash -c 'sudo update-locale LANG=ru_RU.UTF-8'
    ;;
  "chinese")
    sudo lxc-attach -n "$container_name" -- bash -c 'sudo apt-get install language-pack-zh-hans'
    sudo lxc-attach -n "$container_name" -- bash -c 'sudo update-locale LANG=zh_CN.UTF-8'
    ;;
  *)
    echo "Unsupported language. Use 'spanish' for Spanish, 'russian' for Russian, or 'chinese' for Chinese. English will be used by default."
    exit 1
    ;;
esac