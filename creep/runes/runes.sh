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
	#asd
	echo ""
}

function runes.privateKey {
	#a
	echo ""
}

function runes.encrypt {
	# openssl rsautl -encrypt -pubin -inkey $PUBKEY -in .env -out .env.encoded
	echo ""
}

function runes.decrypt {
	echo ""
}
