#!/bin/bash

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

}

function runes.privateKey {
	
}

function runes.encrypt {
	# openssl rsautl -encrypt -pubin -inkey $PUBKEY -in .env -out .env.encoded
}

function runes.decrypt {}
