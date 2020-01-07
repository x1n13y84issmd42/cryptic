#!/bin/bash

source creep/git.sh

# A logging function.
function runes.log {
	_IFS=$IFS && IFS='' && echo -en "\e[35mrunes\e[0m" $@ >&2 && echo -en "$lcX\n" >&2 && IFS=$_IFS
}

# Initalizes the thing by checking for presence of needed files,
# giving some hints on where to obtain them on case they're missing,
# and, if everything is in place, reading the .runes file.
function runes.load {
	local runesFile=.creep/.runes
	local pubKeyFile=.creep/runes.public.key
	local privKeyFile=.creep/runes.private.key

	runes.log "Loading..."
	
	# Checking for the .runes file
	if [[ -f $runesFile ]]; then
		readarray RUNES < $runesFile

		if [[ ! (-f $pubKeyFile && -f $privKeyFile) ]]; then
			runes.log "${lcErr}You don't have any keys to encrypt your content with."
			runes.log "${lcHint}Create a pair of keys by running ${lcCmd}creep/runes/keygen.sh${lcX}."
			runes.log "${lcHint}You can also use your own keys by storing them as ${lcCmd}${pubKeyFile}${lcHint} and ${lcCmd}${privKeyFile}"
			return 255
		fi
	else
		runes.log "You don't have a runes file. ${lcHint}Create a ${lcCmd}${runesFile}${lcHint} file in your project root to start using the encryption."
		# It's not an error though.
	fi

	return 0
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
	local file=.creep/runes.public.key
	if [[ -f $file ]]; then
		echo $file
	fi
}

# Outputs a path to the private key file.
function runes.privateKey {
	local file=.creep/runes.private.key
	if [[ -f $file ]]; then
		echo $file
	fi
}

HAS_PASSKEY="nah"

# Outputs a path to a passkey file, generating it along the way when needed.
# Usually it's once per commit.
function runes.passKey {
	local file=.creep/runes.pass.key

	if [[ $HAS_PASSKEY == "nah" ]]; then
		runes.log "Generating a new passkey file..."
		openssl rand -hex 128 > $file
		HAS_PASSKEY="ye"
	fi

	echo $file
}

# Encrypts a single file with a passkey which is generated once per commit.
# Arguments:
#	@1 A path to a file to encrypt.
function runes.encrypt {
	local passKey=$(runes.passKey)
	runes.log "Encrypting $1 with a $passKey"
	openssl enc -aes-256-cbc -pass file:$passKey -in $1 -out $1
}

# Finalizes the encryption by encrypting the passkey file and adding it to the repository.
function runes.encrypt.finish {
	local pubKey=$(runes.publicKey)
	local passKey=$(runes.passKey)
	runes.log "Finalizing the encryption by encrypting the $passKey file..."
	openssl rsautl -encrypt -pubin -inkey $pubKey -in $passKey -out $passKey

	runes.log "Adding it to the repository..."
	git.add $passKey
	runes.log "\o/"
}

# Initializes the decryption process by decrypting the passkey file first.
function runes.decrypt.start {
	local privKey=$(runes.privateKey)
	local passKey=$(runes.passKey)
	openssl rsautl -decrypt -inkey $privKey -in $passKey -out $passKey
}

# Decrypts a single file with a passkey which is generated once per commit.
# Arguments:
#	@1 A path to a file to decrypt.
function runes.decrypt {
	local privKey=$(runes.privateKey)
	local passKey=$(runes.passKey)
	runes.log "Decrypting $1 with a $passKey"
	openssl enc -d -aes-256-cbc -pass file:$passKey -in $1 -out $1
}
