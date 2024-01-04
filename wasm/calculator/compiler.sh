#!/bin/sh

zig build-exe -dynamic -rdynamic -target wasm32-freestanding -O ReleaseSmall main.zig