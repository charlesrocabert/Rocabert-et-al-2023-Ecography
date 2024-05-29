#!/bin/bash
# coding: utf-8

bash make_clean.sh
cmake -DCMAKE_BUILD_TYPE=Release ..
make
