#!/bin/bash

# base funcs
usage() { echo "usage: $0 <filer location>"; exit 64; }
die() {
    printf '%s\n' "$*" >&2
    [[ "$hlpmsg" == "" ]] || printf '\nPROTIP - %s\n' "$hlpmsg"
    exit 1
}

trap 'exit 255' SIGINT
#vars
hlpmsg=""
bucket="sync-appsec"
RANDOM=$$$(date +%s)
success() {
    e=("ヽ(°〇°)ﾉ" "(°ロ°) !" "(^０^)ノ" "(⌒ω⌒)ﾉ" "(∩ᄑ_ᄑ)⊃━☆ﾟ*･｡*･:≡( ε:)" "╰( ͡° ͜ʖ ͡° )つ──☆*:・ﾟ" "( ͡° ͜ʖ ͡°)" "ଘ(੭ˊᵕˋ)੭* ੈ✩‧₊˚")
    printf '\nCOMPLETE   %s\n' "${e[$RANDOM%${#e[@]}]}"
    exit 0
}

# Set default aws region
[[ "$AWS_DEFAULT_REGION" == "" ]] && AWS_DEFAULT_REGION="$AWS_REGION"
[[ "$AWS_DEFAULT_REGION" == "" ]] && AWS_DEFAULT_REGION="ap-southeast-2"

# check args
[[ "$#" -lt 1 ]] && usage

# dependency check
echo -n "checking dependencies"
deps=(aws)
missing=()
for dep in "${deps[@]}"; do
    echo -n "."
    hash "$dep" 2>/dev/null || missing+=("$dep")
done
[[ "${#missing[@]}" -gt 0 ]] && die "missing deps: ${missing[*]}"
hlpmsg="auth failed against AWS API, your credentials might have expired, if you are using a federeded identity endpoint try re-authing"
aws sts get-caller-identity &>/dev/null || die " (fail) unable to connect to AWS"
hlpmsg=""
echo -n " "

find $1 -type file -print0 | while IFS= read -r -d '' file
do
    #echo "$file"
    #Get file path
    path=$(dirname "${file}")
    #Get base
    base=$(basename "${file}")
    #Sync one file at the time to run some validations
    result=$(aws s3 sync $path s3://$bucket/${path#/} --exclude='*' --include=$base --output text)
    if [ -z "$result" ]; then
      #Get eTag for this object in s3
      eTag=$(aws s3api head-object --bucket $bucket --key ${path#/}/$base --query ETag --output text)
      echo $eTag
      #Calculate eTag on local file
      
      echo "$file was found in filer and it is identical in s3"
    else
      echo $result
    fi

done

success
