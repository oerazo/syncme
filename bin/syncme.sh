#!/bin/bash

# base funcs
usage() { echo "usage: $0 <filerLocation>"; exit 64; }
die() {
    printf '%s\n' "$*" >&2
    exit 1
}


# Set default aws region
[[ "$AWS_DEFAULT_REGION" == "" ]] && AWS_DEFAULT_REGION="$AWS_REGION"
[[ "$AWS_DEFAULT_REGION" == "" ]] && AWS_DEFAULT_REGION="ap-southeast-2"

trap "die received SIGINT" SIGINT

# check args
[[ "$#" -lt 1 ]] && usage

find $1 -print0 | while IFS= read -r -d '' file
do
    echo "$file"
done


