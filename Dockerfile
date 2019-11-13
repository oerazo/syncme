# hadolint ignore=DL3007
FROM alpine:latest as base

# hadolint ignore=DL3018
RUN apk add --update --no-cache bash curl unzip openssh python3 openssl \
    && rm -rf /var/cache/apk/*

#WORKDIR /usr/local/bin

# latest awscli
# hadolint ignore=DL3013
RUN python3 -m ensurepip \
    && pip3 install --upgrade pip \
    && pip3 install --no-cache-dir awscli boto3 \
    && ln -s /usr/bin/python3 /usr/bin/python
