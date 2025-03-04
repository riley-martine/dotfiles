#!/bin/bash

set -e

kebabToCamel() {
	ex -s <<-EOF
		vi
		i$1Q%s/-\(.\)/\U\1/g
		%p
		q!
	EOF
}

kebabToCamel "hello-world"
kebabToCamel "hello-world-again"
