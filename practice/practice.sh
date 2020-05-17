#!/bin/bash

cd $(dirname $(readlink -f $0))
readonly cli=sonic-pi-tool

run() {
  # Pick an exercise
  local readonly exercise=$(
    find -iname '*.rb' | \
    sort --random-sort | \
    head -n1
  )

  # Present the instruction
  clear
  awk '/^#/ { print; next } // { quit }' "${exercise}"
  read -p "Press enter to start..."

  # Start the exercise
  local readonly tmp="$(mktemp --suffix .rb)"
  local readonly startts="$(date +%s)"
  cat "${exercise}" > "${tmp}"
  "${cli}" < "${tmp}"
  vim $tmp

  # Finish the exercise
  "${cli}" stop
  "${cli}" clear
  local readonly endts=$(date +%s)
  clear
  echo "Exercise took $((${endts} - ${startts})) seconds"
  read -p "Press enter for the next exercise..."
  rm "${tmp}"
}

while :; do
  run
done
