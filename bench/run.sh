#!/bin/bash

elm-make Display.elm --output display.js
elm-make --yes "$@" --output elm.js >/dev/null && node run.js | node parse.js
