#!/bin/bash

#
# Options files are passed to the Rosetta binaries, but any command line flags will override the option in the file.
#

# Read in variable values
printf "Enter loop sample size: "
read NUM_LOOPS
printf "Enter docking sample size: "
read NUM_DOCKS
printf "Enter number of best loops to pick: "
read NUM_BEST_LOOPS

IN_FILES=( loop-modeling/input_files/*.pdb)

printf "Enter password for sudo: "
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
echo $SUDO_PASS | sudo -S ./loop-modeling/best_loops.py "${NUM_BEST_LOOPS}"




# Run pre-packing protocol on all best loops for both pH values
BEST_LOOPS_FILE="./loop-modeling/output_files/best_loops.txt"
while IFS=$'\t' read -r file score; do

	pdb=${file%.*} # remove the file extension

	echo "$file"
	echo "$pdb"
	echo "${pdb##*/}"
	echo "pre-packing/${pdb##*/}/6.25/input_files/${pdb##*/}.pdb"

	echo "Setting up pre-pack for ${pdb} @ pH=6.25"
	echo $SUDO_PASS | sudo -S mkdir -p "pre-packing/${pdb##*/}/6.25/input_files"
	echo $SUDO_PASS | sudo -S mkdir -p "pre-packing/${pdb##*/}/6.25/output_files"
	echo $SUDO_PASS | sudo -S cp "loop-modeling/output_files/${file}" "pre-packing/${pdb##*/}/6.25/input_files/"

	echo "Running docking pre-packing protocol"

	# Run the pre-pack script on the individual pdb file
	echo $SUDO_PASS | sudo -S /$ROSETTA3/main/source/bin/docking_prepack_protocol.static.linuxgccrelease -docking:partners A_E -out:suffix "_packed" -out:no_nstruct_label 1 -in:file:s "pre-packing/${pdb##*/}/6.25/input_files/${pdb##*/}.pdb" -out:path:all "pre-packing/${pdb##*/}/6.25/output_files" -pH:pH_mode -pH:value_pH 6.25 -score:weights "pre-packing/pH_pack.wts"

	echo "Setting up pre-pack for ${pdb} @ pH=7.50"
	echo $SUDO_PASS | sudo -S mkdir -p "pre-packing/${pdb##*/}/7.50/input_files"
	echo $SUDO_PASS | sudo -S mkdir -p "pre-packing/${pdb##*/}/7.50/output_files"
	echo $SUDO_PASS | sudo -S cp "loop-modeling/output_files/${file}" "pre-packing/${pdb##*/}/7.50/input_files/"

	echo "Running docking pre-packing protocol"

	# Run the pre-pack script on the individual pdb file
	echo $SUDO_PASS | sudo -S /$ROSETTA3/main/source/bin/docking_prepack_protocol.static.linuxgccrelease -docking:partners A_E -out:suffix "_packed" -out:no_nstruct_label 1 -in:file:s "pre-packing/${pdb##*/}/7.50/input_files/${pdb##*/}.pdb" -out:path:all "pre-packing/${pdb##*/}/7.50/output_files" -pH:pH_mode -pH:value_pH 7.50 -score:weights "pre-packing/pH_pack.wts"

done < "$BEST_LOOPS_FILE"

# Testing break point
exit 0

# counter for testing
i=0
# for each loop... make a new directory for it and run the docking script against it
for folder in ./pre-packing/*/; do

	file=${folder%/}
	file="${file##*/}_packed.pdb" # find output file
	pdb="${file%.*}" # remove file extension

	echo $i
	echo $folder
	echo $file
	echo $pdb
	echo $NUM_DOCKS

	# make new directories and copy over the pdb file
	echo "Setting up docking at pH=6.25 for ${pdb}"
	echo $SUDO_PASS | sudo -S mkdir -p "docking/${pdb}/6.25/"
	echo $SUDO_PASS | sudo -S mkdir -p "docking/${pdb}/6.25/input_files"
	echo $SUDO_PASS | sudo -S mkdir -p "docking/${pdb}/6.25/output_files"
	echo $SUDO_PASS | sudo -S cp "${folder}6.25/output_files/$file" "docking/${pdb}/6.25/input_files/"

	echo "Generating docking sample"
	# run the docking script for 100? docks
	echo $SUDO_PASS | sudo -S /$ROSETTA3/main/source/bin/docking_protocol.static.linuxgccrelease @"${DOCKING_OPTIONS}" -in:file:s "docking/${pdb}/6.25/input_files/$file" -out:path:all "docking/${pdb}/6.25/output_files" -nstruct $NUM_DOCKS -pH:pH_mode -pH:value_pH 6.25 -pack_patch pH_pack -high_patch pH_dock -high_min_patch pH_min
	echo "Docking sample generated"

	# make new directories and copy over the pdb file
	echo "Setting up docking at pH=7.50 for ${pdb}"
	echo $SUDO_PASS | sudo -S mkdir -p "docking/${pdb}/7.50/"
	echo $SUDO_PASS | sudo -S mkdir -p "docking/${pdb}/7.50/input_files"
	echo $SUDO_PASS | sudo -S mkdir -p "docking/${pdb}/7.50/output_files"
	echo $SUDO_PASS | sudo -S cp "${folder}7.50/output_files/$file" "docking/${pdb}/7.50/input_files/"

	echo "Generating docking sample"
	# run the docking script for 100? docks
	echo $SUDO_PASS | sudo -S /$ROSETTA3/main/source/bin/docking_protocol.static.linuxgccrelease @"${DOCKING_OPTIONS}" -in:file:s "docking/${pdb}/7.50/input_files/$file" -out:path:all "docking/${pdb}/7.50/output_files" -nstruct $NUM_DOCKS -pH:pH_mode -pH:value_pH 7.50 -pack_patch pH_pack -high_patch pH_dock -high_min_patch pH_min
	echo "Docking sample generated"
	((i=i+1))
done

echo "Run Complete"
