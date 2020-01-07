#!/bin/bash

source git.sh

# Checks if a progrma is installed in the system.
# For use in if conditions.
function sys.Installed {
	local prog=$(command -v $1)
	if [[ -z $prog ]]; then
		return 255
	else
		return 0
	fi
}
