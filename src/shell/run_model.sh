#!/bin/bash

#
# Options files are passed to the Rosetta binaries, but any command line flags will override the option in the file.
#
echo "Enter loop sample size: "
read NUM_LOOPS
echo "Enter docking sample size: "
read NUM_DOCKS
IN_FILES=( loop-modeling/input_files/*.pdb)
echo "Enter password for sudo: "
read -s SUDO_PASS

LOOP_FLAG_FILE="$(find . -name flag_basic_KIC*)"
echo "Loop flag file found: ${LOOP_FLAG_FILE}"

echo "Generating loop sample"
# generate the loops and store in loop-modeling/output_files/
echo $SUDO_PASS | sudo -S /$ROSETTA3/main/source/bin/loopmodel.static.linuxgccrelease @"${LOOP_FLAG_FILE}" -in:file:s "${IN_FILES[0]}" -nstruct $NUM_LOOPS

echo "Loop sample generated"

# for each loop... make a new directory for it and run the docking script against it
for file in ./loop-modeling/output_files/*.pdb; do

	pdb=${file%.*} # remove the file extension

	# make new directory
	echo "Making directories for ${pdb}"
	echo $SUDO_PASS | sudo -S mkdir -p "docking/${pdb##*/}"
	echo $SUDO_PASS | sudo -S mkdir -p "docking/${pdb##*/}/input_files"
	echo $SUDO_PASS | sudo -S mkdir -p "docking/${pdb##*/}/output_files"
	echo $SUDO_PASS | sudo -S cp "${file}" "docking/${pdb##*/}/input_files/"

	echo "Generating docking sample"
	# run the docking script for 100? docks
	echo $SUDO_PASS | sudo -S /$ROSETTA3/main/source/bin/docking_protocol.static.linuxgccrelease -in:file:s "docking/${pdb##*/}/input_files/${pdb##*/}.pdb" -out:path:all "docking/${pdb##*/}/output_files" -nstruct $NUM_DOCKS
	echo "Docking sample generated"

done

echo "Run Complete"
