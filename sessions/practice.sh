#!/bin/bash

cd $(dirname $(readlink -f $0))

session=$1; shift

src="$(
  find -iname '*.rb' | \
    egrep -v "^./log/" | \
    egrep "${session}" | \
    head -n1 | \
    sed -e 's#^./##'
)"

if !([ -f "${src}" ] && [ -n "${src}" ]); then
  echo "Session \"${session}\" not found"
  exit 1
fi

dst="$(
  echo log/"$(
    echo ${src} | sed -e 's#.rb##' -e 's#/#_#g'
  )"-"$(
    date +%Y-%m-%d-%H:%M:%S
  )".rb
)"

vim "${src}" -c "vsplit ${dst}"
