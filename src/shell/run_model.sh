#!/bin/bash

#
# Options files are passed to the Rosetta binaries, but any command line flags will override the option in the file.
#

# Read in variable values
echo "Enter loop sample size: "
read NUM_LOOPS
echo "Enter docking sample size: "
read NUM_DOCKS
IN_FILES=( loop-modeling/input_files/*.pdb)
echo "Enter password for sudo: "
read -s SUDO_PASS



# Find the option files necessary for modeling
LOOP_FLAG_FILE="$(find . -name flag_basic_KIC*)"
DOCKING_OPTIONS="$(find . -name dock_opts)"
PRE_PACK_OPTS="$(find . -name pre_pack_opts)"
echo "Loop flag file found: ${LOOP_FLAG_FILE}"
echo "Docking options file found: ${DOCKING_OPTIONS}"
echo "Pre-packing options file found: ${PRE_PACK_OPTS}"





# generate the loops and store in loop-modeling/output_files/
echo "Generating loop sample"
echo $SUDO_PASS | sudo -S /$ROSETTA3/main/source/bin/loopmodel.static.linuxgccrelease @"${LOOP_FLAG_FILE}" -in:file:s "${IN_FILES[0]}" -nstruct $NUM_LOOPS
echo "Loop sample generated"
echo "Copying best loops to pre-pack directory"




# Run best loop finder pythons script
echo $SUDO_PASS | sudo -S ./loop-modeling/best_loops.py 2




# Run pre-packing protocol on all best loops for both pH values
BEST_LOOPS_FILE="./loop-modeling/output_files/best_loops.txt"
while IFS=$'\t' read -r file score; do

	pdb=${file%.*} # remove the file extension
	echo "Setting up pre-pack for ${pdb} @ pH=6.25"
	echo $SUDO_PASS | sudo -S mkdir -p "pre-packing/${pdb##*/}/6.25/input_files"
	echo $SUDO_PASS | sudo -S mkdir -p "pre-packing/${pdb##*/}/6.25/output_files"
	echo $SUDO_PASS | sudo -S cp "loop-modeling/output_files/${file}" "pre-packing/${pdb##*/}/6.25/input_files/"

	echo "Running docking pre-packing protocol"
	# Run the pre-pack script on the individual pdb file
	echo $SUDO_PASS | sudo -S /$ROSETTA3/main/source/bin/docking_prepack_protocol.static.linuxgccrelease @"$PRE_PACK_OPTS" -in:file:s "pre-packing/${pdb##*/}/6.25/input_files/${pdb##*/}.pdb" -out:path:all "pre-packing/${pdb##*/}/6.26/output_files" -pH:pH_mode -pH:value_pH = 6.25 -core:weights pH_pack.wts

	echo "Setting up pre-pack for ${pdb} @ pH=7.50"
	echo $SUDO_PASS | sudo -S mkdir -p "pre-packing/${pdb##*/}/7.50/input_files"
	echo $SUDO_PASS | sudo -S mkdir -p "pre-packing/${pdb##*/}/7.50/output_files"
	echo $SUDO_PASS | sudo -S cp "loop-modeling/output_files/${file}" "pre-packing/${pdb##*/}/7.50/input_files/"

	echo "Running docking pre-packing protocol"
	# Run the pre-pack script on the individual pdb file
	echo $SUDO_PASS | sudo -S /$ROSETTA3/main/source/bin/docking_prepack_protocol.static.linuxgccrelease @"$PRE_PACK_OPTS" -in:file:s "pre-packing/${pdb##*/}/7.50/input_files/${pdb##*/}.pdb" -out:path:all "pre-packing/${pdb##*/}/7.50/output_files" -pH:pH_mode -pH:value_pH = 7.50 -core:weights pH_pack.wts

done < "$BEST_LOOPS_FILE"





# for each loop... make a new directory for it and run the docking script against it
for folder in ./pre-packing/; do

	file=${$folder/6.25/output_files/*.pdb} # find output file
	pdb="${file%.*}" # remove file extension

	# make new directories and copy over the pdb file
	echo "Setting up docking at pH=6.25 for ${pdb}"
	echo $SUDO_PASS | sudo -S mkdir -p "docking/${pdb##*/}/6.25/"
	echo $SUDO_PASS | sudo -S mkdir -p "docking/${pdb##*/}/6.25/input_files"
	echo $SUDO_PASS | sudo -S mkdir -p "docking/${pdb##*/}/6.25/output_files"
	echo $SUDO_PASS | sudo -S cp "${$folder/6.25/output_files/$file}" "docking/${pdb##*/}/6.25/input_files/"

	echo "Generating docking sample"
	# run the docking script for 100? docks
	echo $SUDO_PASS | sudo -S /$ROSETTA3/main/source/bin/docking_protocol.static.linuxgccrelease @"${DOCKING_OPTIONS}" -in:file:s "docking/${pdb##*/}/6.25/input_files/${pdb##*/}.pdb" -out:path:all "docking/${pdb##*/}/6.25/output_files" -nstruct $NUM_DOCKS -pH:pH_mode -pH:value_pH 6.25 -pack_patch pH_pack -high_patch pH_dock -high_min_patch pH_min
	echo "Docking sample generated"

	# make new directories and copy over the pdb file
	echo "Setting up docking at pH=7.50 for ${pdb}"
	echo $SUDO_PASS | sudo -S mkdir -p "docking/${pdb##*/}/7.50/"
	echo $SUDO_PASS | sudo -S mkdir -p "docking/${pdb##*/}/7.50/input_files"
	echo $SUDO_PASS | sudo -S mkdir -p "docking/${pdb##*/}/7.50/output_files"
	echo $SUDO_PASS | sudo -S cp "${file}" "docking/${pdb##*/}/7.50/input_files/"

	echo "Generating docking sample"
	# run the docking script for 100? docks
	echo $SUDO_PASS | sudo -S /$ROSETTA3/main/source/bin/docking_protocol.static.linuxgccrelease @"${DOCKING_OPTIONS}" -in:file:s "docking/${pdb##*/}/7.50/input_files/${pdb##*/}.pdb" -out:path:all "docking/${pdb##*/}/7.50/output_files" -nstruct $NUM_DOCKS -pH:pH_mode -pH:value_pH 7.50 -pack_patch pH_pack -high_patch pH_dock -high_min_patch pH_min
	echo "Docking sample generated"

done

echo "Run Complete"
