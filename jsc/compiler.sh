#!/bin/bash

zig build

cd ./zig-out/bin/ 

./lar run index.js               

cd ../../