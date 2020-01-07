#!/bin/bash

PUB=.creep/runes.public.key
PRIV=.creep/runes.private.key

openssl genrsa -aes256 -out $PRIV 1024\
&&\
openssl rsa -in $PRIV -out $PRIV\
&&\
openssl rsa -in $PRIV -pubout -out $PUB