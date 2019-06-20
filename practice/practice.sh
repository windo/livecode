#!/bin/bash

cd $(dirname $(readlink -f $0))

run() {
  # Pick an exercise
  exercise=$(
    find -iname '*.rb' | \
    sort --random-sort | \
    head -n1
  )

  # Present the instruction
  clear
  awk '/^#/ { print; next } // { quit }' $exercise
  read -p "Press enter to start..."

  # Start the exercise
  tmp=$(mktemp --suffix .rb)
  startts=$(date +%s)
  cat $exercise > $tmp
  sonic_pi_cli < $tmp
  vim $tmp

  # Finish the exercise
  sonic_pi_cli stop
  sonic_pi_cli clear
  endts=$(date +%s)
  clear
  echo "Exercise took $(($endts - $startts)) seconds"
  read -p "Press enter for the next exercise..."
  rm $tmp
}

while :; do
  run
done
