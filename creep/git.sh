#!/bin/sh

function git.status {
	git status --porcelain
}

function git.add {
	git add $1
}
