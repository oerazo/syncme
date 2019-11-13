#!/bin/bash

# base funcs
usage() { echo "usage: $0 <filer location> <bucket>"; exit 64; }
die() {
    printf '%s\n' "$*" >&2
    [[ "$hlpmsg" == "" ]] || printf '\nPROTIP - %s\n' "$hlpmsg"
    exit 1
}
hlpmsg=""

trap 'exit 255' SIGINT
docker  build -t sync:1.0 .

docker run --rm -it \
    -e AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-ap-southeast-2}" \
    -v "$HOME/.aws:/root/.aws" \
    -v "$1:/$1" \
    -v "$PWD:/src" \
    sync:1.0 \
    bash ./src/bin/syncme.sh $1 $2 \
    || die "unable to execute docker image or command"
