![Alt text](images/rb_logo.png?raw=true "logo")
## Resurrect Bio PDB Processing Pipeline
These pipelines were developed to increase throughput and accuracy of processing AF2 output PDBs. 

Protocol developed:
1. Implementation of [pDockQ](https://www.nature.com/articles/s41467-022-28865-w) from the [FoldDock](https://gitlab.com/ElofssonLab/FoldDock) repo. The main change here is adding a lower distance threshold to stop impossible complexes scoring so highly, and adding the PPV confidence threshold.
2. Using `MDanalysis` to identify the position of residues in a 2 chain complex that are within a reasonable distance indicating interaction. 
3. Using the output of RB's PLANT pipeline `NLR_Domains.tsv` output, to identify the location of the putative interactions.

Usage:
