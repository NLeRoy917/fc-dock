#!/bin/bash

echo "Setting up directories..."
sudo mkdir -p WT/loop-modeling/input_files
sudo mkdir -p WT/loop-modeling/output_files
sudo mkdir -p WT/pre-packing
sudo mkdir -p WT/docking

sudo mkdir -p LS/loop-modeling/input_files
sudo mkdir -p LS/loop-modeling/output_files
sudo mkdir -p LS/pre-packing
sudo mkdir -p LS/docking

sudo mkdir -p YTE/loop-modeling/input_files
sudo mkdir -p YTE/loop-modeling/output_files
sudo mkdir -p YTE/pre-packing
sudo mkdir -p YTE/docking

sudo mkdir -p YTE-LS/loop-modeling/input_files
sudo mkdir -p YTE-LS/loop-modeling/output_files
sudo mkdir -p YTE-LS/pre-packing
sudo mkdir -p YTE-LS/docking

sudo mkdir -p mouse/loop-modeling/input_files
sudo mkdir -p mouse/loop-modeling/output_files
sudo mkdir -p mouse/pre-packing
sudo mkdir -p mouse/docking

echo "Copying and moving files and changing permissions"

# Move wildtype files and set up wildtype directories
sudo cp src/pdbs/Fc-FcRn-WT.pdb ./WT/loop-modeling/input_files/
sudo cp src/options/fc.loop ./WT/loop-modeling/input_files
sudo cp src/options/flag_basic_KIC ./WT/loop-modeling/input_files
sudo cp src/options/dock_opts ./WT/docking
sudo cp src/shell/run_model.sh ./WT
sudo cp src/analysis/docking_analysis.py ./WT
sudo cp src/util/reset_dir.sh ./WT
sudo cp src/analysis/best_loops.py ./WT/loop-modeling/
sudo chmod +x ./WT/docking_analysis.py
sudo chmod +x ./WT/run_model.sh
sudo chmod +x ./WT/reset_dir.sh
sudo chmod +x ./WT/loop-modeling/best_loops.py

# Move LS files and set up LS directories
sudo cp src/pdbs/Fc-FcRn-LS.pdb ./LS/loop-modeling/input_files/
sudo cp src/options/fc.loop ./LS/loop-modeling/input_files
sudo cp src/options/flag_basic_KIC ./LS/loop-modeling/input_files
sudo cp src/options/dock_opts ./LS/docking
sudo cp src/shell/run_model.sh ./LS
sudo cp src/analysis/docking_analysis.py ./LS
sudo cp src/util/reset_dir.sh ./LS
sudo cp src/analysis/best_loops.py ./LS/loop-modeling/
sudo chmod +x ./LS/docking_analysis.py
sudo chmod +x ./LS/run_model.sh
sudo chmod +x ./LS/reset_dir.sh
sudo chmod +x ./LS/loop-modeling/best_loops.py

# Move YTE files and set up YTE directories
sudo cp src/pdbs/Fc-FcRn-YTE.pdb ./YTE/loop-modeling/input_files/
sudo cp src/options/fc.loop ./YTE/loop-modeling/input_files
sudo cp src/options/flag_basic_KIC ./YTE/loop-modeling/input_files
sudo cp src/options/dock_opts ./YTE/docking
sudo cp src/shell/run_model.sh ./YTE
sudo cp src/analysis/docking_analysis.py ./YTE
sudo cp src/util/reset_dir.sh ./YTE
sudo cp src/analysis/best_loops.py ./YTE/loop-modeling/
sudo chmod +x ./YTE/docking_analysis.py
sudo chmod +x ./YTE/run_model.sh
sudo chmod +x ./YTE/reset_dir.sh
sudo chmod +x ./YTE/loop-modeling/best_loops.py

# Move YTE-LS files and set up YTE-LS directories
sudo cp src/pdbs/Fc-FcRn-YTE-LS.pdb ./YTE-LS/loop-modeling/input_files/
sudo cp src/options/fc.loop ./YTE-LS/loop-modeling/input_files
sudo cp src/options/flag_basic_KIC ./YTE-LS/loop-modeling/input_files
sudo cp src/options/dock_opts ./YTE-LS/docking
sudo cp src/shell/run_model.sh ./YTE-LS
sudo cp src/analysis/docking_analysis.py ./YTE-LS
sudo cp src/util/reset_dir.sh ./YTE-LS
sudo cp src/analysis/best_loops.py ./YTE-LS/loop-modeling/
sudo chmod +x ./YTE-LS/docking_analysis.py
sudo chmod +x ./YTE-LS/run_model.sh
sudo chmod +x ./YTE-LS/reset_dir.sh
sudo chmod +x ./YTE-LS/loop-modeling/best_loops.py

# Move Mouse files and set up mouse directories
sudo cp src/pdbs/Fc-FcRn-mouse.pdb ./mouse/loop-modeling/input_files/
sudo cp src/options/fc_mouse.loop ./mouse/loop-modeling/input_files
sudo cp src/options/flag_basic_KIC_mouse ./mouse/loop-modeling/input_files
sudo cp src/options/dock_opts ./mouse/docking
sudo cp src/shell/run_model.sh ./mouse
sudo cp src/analysis/docking_analysis.py ./mouse
sudo cp src/util/reset_dir.sh ./mouse
sudo cp src/analysis/best_loops.py ./mouse/loop-modeling/
sudo chmod +x ./mouse/docking_analysis.py
sudo chmod +x ./mouse/run_model.sh
sudo chmod +x ./mouse/reset_dir.sh
sudo chmod +x ./mouse/loop-modeling/best_loops.py

echo "Done!"