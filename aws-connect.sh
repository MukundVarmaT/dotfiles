#!/bin/bash

CACHE="$HOME/dotfiles/misc/.aws-save.txt"

if [ ! -f $CACHE ]; then
    echo '' > $CACHE
fi

declare -A key_dict

while read line; do
    key=$(echo $line | cut -d "|" -f1)
    value=$(echo $line | cut -d "|" -f2)
    if [[ ${key} ]]; then
        key_dict[$key]="$value"
    fi
done < $CACHE

pem_file=$1

if [[ ! ${key_dict[$pem_file]} ]]; then
    key_dict["$pem_file"]="$2"
    ip=$2
elif [ $2 ]; then
    key_dict["$pem_file"]="$2"
    ip=$2
else
    ip=${key_dict[$pem_file]}
fi

for key in "${!key_dict[@]}"; do
    echo "$key|${key_dict[$key]}"
done > $CACHE

ssh -i "$HOME/dotfiles/misc/aws-pem/$pem_file.pem" "ubuntu@$ip"
