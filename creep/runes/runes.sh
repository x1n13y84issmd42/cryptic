#!/bin/bash

source creep/git.sh

# A logging function.
function runes.log {
	_IFS=$IFS && IFS='' && echo -en "\e[35mrunes\e[0m" $@ >&2 && echo -en "$lcX\n" >&2 && IFS=$_IFS
}

RUNES_FILE=.creep/.runes
PUB_KEY_FILE=.creep/runes.public.key
PRIV_KEY_FILE=.creep/runes.private.key
PASS_KEY_FILE=.creep/runes.pass.key

# Initalizes the thing by checking for presence of needed files,
# giving some hints on where to obtain them on case they're missing,
# and, if everything is in place, reading the .runes file.
function runes.load {
	runes.log "Loading..."
	
	# Checking for the .runes file
	if [[ -f $RUNES_FILE ]]; then
		# Reading it
		readarray RUNES < $RUNES_FILE

		if [[ ! -f $PUB_KEY_FILE ]]; then
			runes.log "${lcErr}You don't have a public key to encrypt your content with, so you won't be able to commit to this repository."
		fi

		if [[ ! -f $PRIV_KEY_FILE ]]; then
			runes.log "${lcErr}You don't have a private key to decrypt your content with, so you won't be able to access contents of some files from this repository."
		fi

		if [[ ! (-f $PUB_KEY_FILE && -f $PRIV_KEY_FILE) ]]; then
			runes.log "${lcHint}Create a pair of keys by running ${lcCmd}creep/runes/keygen.sh${lcX}."
		fi;

		runes.load.passKey;
	else
		runes.log "You don't have a runes file. ${lcHint}Create a ${lcCmd}${RUNES_FILE}${lcHint} file in your project root to start using the encryption."
	fi
}

# Generates a new passkey file.
# Usually it's used once per commit.
function runes.load.passKey {
	runes.log "Generating a new passkey file..."
	openssl rand -hex 128 > $PASS_KEY_FILE
}

# Checks if the given path belongs to the runes file.
# Arguments:
#	@1	A file path to check.
function runes.isRune {
	for RUNE in ${RUNES[@]}; do
		if [[ $RUNE == $1 ]]; then
			return 0
		fi
	done

	return 255
}

# Outputs a path to the public key file.
function runes.publicKey {
	if [[ -f $PUB_KEY_FILE ]]; then
		echo $PUB_KEY_FILE
	fi
}

# Outputs a path to the private key file.
function runes.privateKey {
	if [[ -f $PRIV_KEY_FILE ]]; then
		echo $PRIV_KEY_FILE
	fi
}

# Outputs a path to a passkey file.
function runes.passKey {
	if [[ ! -f PASS_KEY_FILE ]]; then
		runes.new.passKey;
	fi

	echo $PASS_KEY_FILE
}

# Encrypts a single file with a passkey which is generated once per commit.
# Arguments:
#	@1 A path to a file to encrypt.
function runes.encrypt {
	if runes.encrypt.precondition "encrypt" $1; then
		local passKey=$(runes.passKey)
		runes.log "Encrypting $1 with a $passKey"
		openssl enc -aes-256-cbc -pass file:$passKey -in $1 -out $1
	fi
}

# Finalizes the encryption by encrypting the passkey file and adding it to the repository.
function runes.encrypt.finish {
	if runes.encrypt.precondition "finish the encryption"; then
		local pubKey=$(runes.publicKey)
		local passKey=$(runes.passKey)
		runes.log "Finalizing the encryption by encrypting the $passKey file..."
		openssl rsautl -encrypt -pubin -inkey $pubKey -in $passKey -out $passKey

		runes.log "Adding it to the repository..."
		git.add $passKey
		runes.log "\o/"
	fi;
}

# Initializes the decryption process by decrypting the passkey file first.
function runes.decrypt.start {
	if runes.decrypt.precondition "start the decryption"; then
		local privKey=$(runes.privateKey)
		local passKey=$(runes.passKey)
		openssl rsautl -decrypt -inkey $privKey -in $passKey -out $passKey
	fi
}

# Decrypts a single file with a passkey which is generated once per commit.
# Arguments:
#	@1 A path to a file to decrypt.
function runes.decrypt {
	if runes.decrypt.precondition "decrypt" $1; then
		local passKey=$(runes.passKey)
		runes.log "Decrypting $1 with a $passKey"
		openssl enc -d -aes-256-cbc -pass file:$passKey -in $1 -out $1
	fi
}

# Checks if it's generally makes sense to try to decrypt something by ensuring
# there is a private key file in place.
# Arguments:
#	$1 A name of operation the precondition is checked for.
#	$2 A file name being decrypted.
function runes.decrypt.precondition {
	local privKey=$(runes.privateKey)
	if [[ ! -f $privKey ]]; then
		runes.log "${lcErr}Cannot $1 $2 because private key is absent."

		return 255
	fi

	return 0
}

# Checks if it's makes sense to try to encrypt something by ensuring
# there is a public key file in place.
# Arguments:
#	$1 A name of operation the precondition is checked for.
#	$2 A file name being decrypted.
function runes.encrypt.precondition {
	local privKey=$(runes.publicKey)
	if [[ ! -f $privKey ]]; then
		runes.log "${lcErr}Cannot $1 $2 because public key is absent."

		return 255
	fi

	return 0
}
