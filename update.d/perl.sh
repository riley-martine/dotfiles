#!/usr/bin/env bash

cpanm --self-upgrade

cpan-outdated -p | cpanm
