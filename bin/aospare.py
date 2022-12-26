#!/usr/bin/env python3
"""Uppercase, uniq, disemvowel, and shuffle input."""

import random
import sys

if len(sys.argv) > 1:
    GIVEN = "".join(sys.argv[1:])
else:
    GIVEN = sys.stdin.read()

letters = list(set(GIVEN.strip().upper()))
random.shuffle(letters)
print(" ".join([l for l in letters if not l in " AEIOU"]))
