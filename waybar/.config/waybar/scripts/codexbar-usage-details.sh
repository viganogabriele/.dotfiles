#!/usr/bin/env bash

clear
printf 'Claude\n======\n'
codexbar usage --provider claude --source oauth --no-color
printf '\nCodex\n=====\n'
codexbar usage --provider codex --source cli --no-color
printf '\nPremi un tasto per chiudere.'
read -rsn1
