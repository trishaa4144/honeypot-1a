#!/bin/bash

# This script updates the language on the container, generates honey,
# and copies the honey onto the machine.

if [[ $# -ne 2 ]]; then
  echo "Provide 2 shells arguments for the container name, and language (english, spanish, russian, chinese)."
  exit 1
fi

container_name=$1
language=$2

echo $language

# Generate honey for respective language. Will save to a folder named "generated"
python3 ../honeymaker.py --language $language

# Add functionality to copy generated files/folders from "generated" folder to the container.
#### < TO DO > ####

# Remove "generated" folder from container
rm -rf generated

sudo lxc-attach -n "$container_name" -- bash -c 'sudo apt-get update'
case $language in
  "english")
    # No need to change language settings for English.
    ;;
  "spanish")
    sudo lxc-attach -n "$container_name" -- bash -c 'sudo apt-get install -y language-pack-es'
    sudo lxc-attach -n "$container_name" -- bash -c 'sudo apt-get update'
    sudo lxc-attach -n "$container_name" -- bash -c 'sudo update-locale LANGUAGE=es_ES.UTF-8'
    ;;
  "russian")
    sudo lxc-attach -n "$container_name" -- bash -c 'sudo apt-get install -y language-pack-ru'
    sudo lxc-attach -n "$container_name" -- bash -c 'sudo apt-get update'
    sudo lxc-attach -n "$container_name" -- bash -c 'sudo update-locale LANGUAGE=ru_RU.UTF-8'
    ;;
  "chinese")
    sudo lxc-attach -n "$container_name" -- bash -c 'sudo apt-get install -y language-pack-zh-hans'
    sudo lxc-attach -n "$container_name" -- bash -c 'sudo apt-get update'
    sudo lxc-attach -n "$container_name" -- bash -c 'sudo update-locale LANGUAGE=zh_CN.UTF-8'
    ;;
  *)
    echo "Unsupported language. Use 'spanish' for Spanish, 'russian' for Russian, 'chinese' for Chinese, and 'english' for English."
    exit 1
    ;;
esac