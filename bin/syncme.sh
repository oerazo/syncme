#!/bin/bash

# base funcs
usage() { echo "usage: $0 <filer location> <bucket>"; exit 64; }
die() {
    printf '%s\n' "$*" >&2
    [[ "$hlpmsg" == "" ]] || printf '\nPROTIP - %s\n' "$hlpmsg"
    exit 1
}

linebreak() { printf '%78s\n' " " | tr ' ' '-'; }

trap 'exit 255' SIGINT

#vars
hlpmsg=""
bucket=$2
RANDOM=$$$(date +%s)
success() {
    e=("ヽ(°〇°)ﾉ" "(°ロ°) !" "(^０^)ノ" "(⌒ω⌒)ﾉ" "(∩ᄑ_ᄑ)⊃━☆ﾟ*･｡*･:≡( ε:)" "╰( ͡° ͜ʖ ͡° )つ──☆*:・ﾟ" "( ͡° ͜ʖ ͡°)" "ଘ(੭ˊᵕˋ)੭* ੈ✩‧₊˚")
    printf '\n\e[34mFile Transfer Complete   %s\e[39m\n' "${e[$RANDOM%${#e[@]}]}"
    exit 0
}
warning() {
  printf "\e[32mWarning: \e[39m $1 \n"
}
# Set default aws region
[[ "$AWS_DEFAULT_REGION" == "" ]] && AWS_DEFAULT_REGION="$AWS_REGION"
[[ "$AWS_DEFAULT_REGION" == "" ]] && AWS_DEFAULT_REGION="ap-southeast-2"

# check args
[[ "$#" -lt 2 ]] && usage

# dependency check
echo; linebreak
echo "checking dependencies"

deps=(aws dd openssl)
missing=()
for dep in "${deps[@]}"; do
    echo -n "."
    hash "$dep" 2>/dev/null || missing+=("$dep")
done
[[ "${#missing[@]}" -gt 0 ]] && die "missing deps: ${missing[*]}"
hlpmsg="auth failed against AWS API, refresh your aws credentials and make sure they are valid"
aws sts get-caller-identity &>/dev/null || die " (fail) unable to connect to AWS"
hlpmsg=""
echo; linebreak

find $1 -type f -print0 | while IFS= read -r -d '' file
do
    #Get file path
    path=$(dirname "${file}")
    #Get base
    base=$(basename "${file}")
    #check if local file exits in s3
    inS3=$(aws s3 ls s3://$bucket/${path#/}/$base)
    [ ! -z "$inS3" ] ||  warning "$file found in filer but not in s3, continuing"
    # Perform some validations
    result=$(aws s3 sync $path s3://$bucket/${path#/} --exclude='*' --include=$base --output text)
    if [ -z "$result" ]; then
      #Get eTag for this object in s3
      eTag=$(aws s3api head-object --bucket $bucket --key ${path#/}/$base --query ETag --output text) || die " (fail) unable to sync file $file"
      #JMESPath returns an escaped json result, as there is no raw option in JMESPath and I dont want to use JQ just for this then Im just removing the quotes
      #This tech debt has been brought to you by me using bash :)
      eTag=${eTag#\"}
      eTag=${eTag%\"}
      #Calculate eTag/md5 on local file - no multipart required
      filerETag=$(openssl md5 $file | awk '{ print $2 }')
      #check file integrity MD5 eTag
      if [ "$eTag" == "$filerETag" ]; then
        echo "$file was found in filer and it is identical in s3 (this includes eTag validation)"
      else
        warning "Check $file as its integrity might have been compromised or a network failure has occurred"
      fi

    else
      if [ ! -z "$inS3" ]; then
        warning "the content of file $file has changed, continuing"
      else
        echo $result
      fi
    fi

done

echo; linebreak
success
