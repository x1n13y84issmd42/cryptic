#!/bin/bash

PUBKEY=public.key

#TODO:
#	check for keys
#	read the .runes files
#	iterate over files there and encrypt them

# openssl rsautl -encrypt -pubin -inkey $PUBKEY -in .env -out .env.encoded