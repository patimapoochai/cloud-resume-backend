#!/usr/bin/env bash
mkdir out
cd src
zip code.zip lambda_function.py
cd -
mv src/code.zip out/
