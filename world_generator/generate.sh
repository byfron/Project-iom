#!/bin/sh

source ~/Projects/IsleOfMan/IOM/bin/activate
python3 world_generator.py
cp world.bin ../maps/
