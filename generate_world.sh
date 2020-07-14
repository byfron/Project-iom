#!/bin/sh

cd proto
./regenerate.sh
cd ../world_generator
./generate.sh
