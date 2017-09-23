#!/bin/bash

elm-make --yes "$@" --output elm.js >/dev/null && node run.js
