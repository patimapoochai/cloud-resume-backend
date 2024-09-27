#!/usr/bin/env bash
mkdir ../out
zip code.zip lambda_function.py
rm ../out/*
mv code.zip ../out/
