#!/bin/bash

function git.status {
	IFS=$'\n'
	git status --porcelain
}

function git.add {
	git add $1
}
