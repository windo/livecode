#!/bin/bash

cd $(dirname $(readlink -f $0))
readonly cli=sonic-pi-tool

filter=${1:-.*}
action=
exercise=

run() {
  # Pick an exercise
  read -p "Next, [R]andom [A]gain [F]ilter [P]ick [Q]uit: " action
  case "$action" in
    r|R|"")
      exercise="$(
        find -iname '*.rb' | \
          egrep -v "^./log/" | \
          egrep "${filter}" | \
          sort --random-sort | \
          head -n1 | \
          sed -e 's#^./##'
      )"
      ;;
    f|F)
      echo "Current filter: ${filter}"
      read -p "New filter: " filter
      continue
      ;;
    p|P)
      echo Exercises:
      find -iname '*.rb' | \
        egrep -v "^./log/" | \
        sed -e 's#^./##'
      read -p "Exercise: " exercise
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
      echo ${exercise} | sed -e 's#.rb##' -e 's#/#_#g'
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
