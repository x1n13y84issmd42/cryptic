#!/bin/bash

source creep/creep.sh
source creep/runes/runes.sh

BITS=${1:-2048}

runes.log "Generating a pair of keys ($BITS bits long) to encrypt your files with."
runes.log "You will be prompted for a passphrase - ${lcHint}don't care about it complexity${lcX}, it will be stripped from the key later."

# Generating the key files
PUB=.creep/runes.public.key
PRIV=.creep/runes.private.key

openssl genrsa -aes256 -out $PRIV $BITS\
&&\
openssl rsa -in $PRIV -out $PRIV\
&&\
openssl rsa -in $PRIV -pubout -out $PUB

# Gitignoring the private key file
runes.log ".gitignoring the $PRIV file..."
echo $PRIV >> .gitignore 

runes.log "Done \o/"
