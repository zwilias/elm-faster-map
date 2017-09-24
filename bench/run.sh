#!/bin/bash

# Clear the "safeguard" json" file beforehand
rm -rf tmp.json

elm-make Display.elm --output display.js >/dev/null
elm-make --yes "$@" --output elm.js >/dev/null &&
  node run.js | tee tmp.json | node parse.js | tee result.tsv
