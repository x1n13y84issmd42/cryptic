#!/bin/bash

function runes.log {
	_IFS=$IFS && IFS='' && echo -e "\e[35mrunes\e[0m" $@ >&2 && IFS=$_IFS
}

# Checks if the given path belongs to the runes file.
function runes.isRune {
	for RUNE in ${RUNES[@]}; do
		if [[ $RUNE == $1 ]]; then
			return 0
		fi
	done

	return 255
}

function runes.publicKey {
	local file=.creep/runes.public.key
	if [[ -f $file ]]; then
		echo $file
	fi
}

function runes.privateKey {
	#a
	echo ""
}

function runes.encrypt {
	local pubKey=$(runes.publicKey)
	runes.log "openssl rsautl -encrypt -pubin -inkey $pubKey -in $1 -out $1"
}

function runes.decrypt {
	echo ""
}
