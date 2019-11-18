#!/bin/bash

# Remove all files from docking folder and re-copy defauly options
echo "Resetting directory"
sudo rm -r docking/*
sudo cp ../src/dock_opts ./docking/

# Remove all files from the loop-modeling output directory
sudo rm -r loop-modeling/output_files/*
echo "Done!"
