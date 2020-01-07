#!/bin/sh

# Checks if the given path belongs to the runes file.
function runes.isRune {
	for RUNE in ${RUNES[@]}; do
		if [[ $RUNE == $1 ]]; then
			return 0
		fi
	done

	return 255
}

function runes.checkKeys {}

function runes.encrypt {}

function runes.decrypt {}
