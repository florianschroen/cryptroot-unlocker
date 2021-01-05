#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
. $DIR/cryptroot-unlocker.conf
TARGET_RSA_NOW=$(ssh-keygen -lf <(ssh-keyscan $TARGET_HOST 2>/dev/null) | grep RSA | cut -d" " -f2)
CONF=$DIR/cryptroot-unlocker.conf



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
    echo "WARNING! Fingerprints do not match, exiting."
    exit 1
fi

ssh -o StrictHostKeyChecking=no root@$TARGET_HOST "printf $TARGET_KEY | cryptroot-unlock"
