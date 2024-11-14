#!/usr/bin/env bash
mkdir out
cd src
zip code.zip *
cd -
mv src/code.zip out/
