#!/bin/bash

target="./browser/benches"
files=("FoldrBench" "FoldrDepth" "MapBench" "MapDepth" "MapUnrolled" "TupleVsPatternFoldrBench" "TupleVsPatternMapBench")

rm -rf "${target}/all.txt"
for file in "${files[@]}"; do
  echo "${file}.js" >> "${target}/all.txt"
  elm-make "${file}.elm" --output "${target}/${file}.js"
done
