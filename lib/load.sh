#!/bin/bash

cd $(dirname $(readlink -f $0))

for f in vj looper midi osc keyboard rythm record-and-cut; do
  sonic-pi-tool eval-file $f.rb
done
