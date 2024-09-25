#!/usr/bin/env bash

zip code.zip lambda_function.py
rm ../out/*
mv code.zip ../out/
