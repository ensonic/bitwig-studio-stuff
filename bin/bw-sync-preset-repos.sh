#!/bin/bash

savepwd=$PWD
trap "cd ${savepwd}" EXIT

cd "$HOME/Bitwig Studio/Library/Presets"
for d in $(find . -type l); do
  echo "syncing ${d}"
  (cd ${d}; git pull --rebase)
done
cd ${savepwd}

