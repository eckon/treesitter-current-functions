#!/usr/bin/env bash

# if one test fails, the whole script will exit with a non-zero exit code
set -e

run() {
  nvim --headless --noplugin -u "scripts/minimal_init.lua" "$1" -l "scripts/print_current_functions.lua"
}

example_path="scripts/examples"
ls "$example_path" | grep -E "^example\..{0,3}\$" | while read -r i; do
  echo -e "Running $i"
  # uncomment to update expected output
  # run "$example_path/$i" &> "$example_path/$i.expected"
  run "$example_path/$i" &> "$example_path/$i.expected.actual"
  diff "$example_path/$i.expected" "$example_path/$i.expected.actual"
done
