#!/bin/bash

function runes.log {
	_IFS=$IFS && IFS='' && echo -en "\e[35mrunes\e[0m" $@ >&2 && echo -en "$lcX\n" >&2 && IFS=$_IFS
}

function runes.load {
	local runesFile=.creep/.runess
	local pubKeyFile=.creep/runes.public.key
	local privKeyFile=.creep/runes.public.key
	
	if [[ -f $runesFile ]]; then
		readarray RUNES < $runesFile

		if [[ ! (-f $pubKeyFile && -f $privKeyFile) ]]; then
			runes.log "${lcErr}You don't have any keys to encrypt your content with."
			runes.log "${lcHint}Create a pair of keys by running ${lcCmd}./creep/runes/keygen.sh."
			return 255
		fi
	else
		runes.log "You don't have a runes file. ${lcHint}Create a ${lcCmd}${runesFile}${lcHint} file in your project root to start using the encryption."
	fi

	return 0
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
