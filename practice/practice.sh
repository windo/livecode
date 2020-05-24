#!/bin/bash

cd $(dirname $(readlink -f $0))
readonly cli=sonic-pi-tool
readonly match=${1:-.*}

run() {
  # Pick an exercise
  local readonly exercise=$(
    find -iname '*.rb' | \
    egrep "${match}" | \
    sort --random-sort | \
    head -n1
  )

  # Present the instruction
  clear
  awk '
    /^#/ { print; next }
    /^$/ { exit }
  ' "${exercise}"
  read -p "Press enter to start..."

  # Start the exercise
  local readonly tmp="$(mktemp --suffix .rb)"
  local readonly startts="$(date +%s)"
  awk '
    /RANDOM_SEED/ { srand(); sub("RANDOM_SEED", int(rand() * 100)) }
    // { print }
  ' "${exercise}" > "${tmp}"
  "${cli}" stop
  "${cli}" eval-file "${tmp}"
  vim $tmp

  # Finish the exercise
  "${cli}" stop
  local readonly endts=$(date +%s)
  clear
  echo "Exercise took $((${endts} - ${startts})) seconds"
  read -p "Press enter for the next exercise..."
  rm "${tmp}"
}

while :; do
  run
done
