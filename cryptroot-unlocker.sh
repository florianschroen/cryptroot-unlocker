#!/bin/bash

DIR="$(readlink -f $( dirname $0))"
CONF=$DIR/cryptroot-unlocker.conf

. $DIR/cryptroot-unlocker.conf
[ $DEBUG ] && set -$DEBUG

TARGET_RSA_NOW=$(ssh-keyscan $TARGET_HOST 2>/dev/null \
    | ssh-keygen -lf - \
    | grep RSA \
    | cut -d" " -f2 \
    )

if [ ! $TARGET_RSA_NOW ]; then
    # empty when server not available
    echo "fingerprint not found. host down?" >&2
    exit 0
fi

# Check if fingerprint is known, if not add to $CONF
if [[ -z $TARGET_RSA ]]; then
    echo "RSA host key fingerprint not known"
    read -p "Accept target RSA fingerprint $TARGET_RSA_NOW from now on? " -n 1 -r
    echo    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi

    TARGET_RSA=$TARGET_RSA_NOW

    if [[ $(grep TARGET_RSA $CONF) ]]; then
        sed -i "s/TARGET_RSA.*/TARGET_RSA=$TARGET_RSA_NOW/" $CONF
    else
        echo "TARGET_RSA=$TARGET_RSA_NOW" >> $CONF
    fi   
fi

# Compare fingerprints
if [[ $TARGET_RSA_NOW != $TARGET_RSA ]]; then
    [ $DEBUG ] && echo "WARNING! Fingerprints do not match, (system running normally) exiting."
    exit 0
fi

printf $TARGET_KEY | ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$TARGET_HOST cryptroot-unlock

# vim: sw=4 ts=4 expandtab
