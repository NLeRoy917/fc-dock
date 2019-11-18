# Fc-Dock v 2.0
---
This is a second iteration to the Fc-FcRn binding model originally proposed and designed to help move towards a framework and pipeline for in silico analysis of antibodies at the IBRI.

This implementation has three (3) unique changes to it:

1. Utilize pHDock v RosettaDock. pHDock has been shown to providea better docking anaylsis through its use of dynamic residue protonation algorithms. In addition, this will help give insight into how our structures binding affinities are affected by changes in pH.

2. Introduce a pre-pack ptorocol. According to the Rosetta documentation, in order to recieve meaningful docking scores and analysis, one needs to run all structures through the side-chain rotamer pre-packing protocol. This will allow us to draw  more significant conclusions on our structures, and hopefully will increase model accuracy.

3. Alter analysis by only examining high-scoring strucutres. In biology, it is well-accepted that thermodynamics and low-energy states drive biological processes - including protein dynamics like folding and docking. Thus, it follows that when presented with 100's of strcutures we should choose only those that score highly from an energetics standpoint to further analyze and draw conclusions from. Finally, we will use the Arrhenius-like equation to relate kD values between structures.


TODO - Model flow
