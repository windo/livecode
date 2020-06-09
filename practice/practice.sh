#!/bin/bash

cd $(dirname $(readlink -f $0))
readonly cli=sonic-pi-tool

filter=${1:-.*}
action=
exercise=

run() {
  # Pick an exercise
  read -p "Next, [R]andom [A]gain [F]ilter [Q]uit: " action
  case "$action" in
    r|R|"")
      exercise="$(
        basename "$(
          find -maxdepth 1 -iname '*.rb' | \
            egrep "${filter}" | \
            sort --random-sort | \
            head -n1
        )"
      )"
      ;;
    f|F)
      echo "Current filter: ${filter}"
      read -p "New filter: " filter
      continue
      ;;
    a|A)
      # Keep the exercise
      ;;
    q|Q)
      exit 0
      ;;
  esac

  # Present the instruction
  clear
  awk '
    /^#/ { print; next }
    /^$/ { exit }
  ' "${exercise}"
  read -p "Press enter to start..."

  # Start the exercise
  local readonly tmp="$(
    echo log/"$(
      echo ${exercise} | sed -e 's#.rb##'
    )"-"$(
      date +%Y-%m-%d-%H:%M:%S
    )".rb
  )"
  local readonly startts="$(date +%s)"
  awk '
    /RANDOM_SEED/ {
      srand();
      sub("RANDOM_SEED", int(rand() * 100));
    }
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
}

while :; do
  run
done
