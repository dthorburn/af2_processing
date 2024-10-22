#!/usr/bin/env nextflow

start_date = new java.util.Date()
log.info """
===============================================================================================
                             Resurrect Bio Alphafold2-Multimer Pipeline
                                   Batch PostProcessing Workflow
===============================================================================================
Started        : ${start_date}
launchDir      : ${workflow.launchDir}
Input Dir      : ${params.PS_input}
Output Dir     : ${params.PS_output}
NLR Domain TSV : ${params.PS_nlrt_domains}
Extract Script : ${params.extract_coords_script}
Overlay Script : ${params.overlay_coords_script}

Author: Doko-Miles Thorburn <miles@resurrect.bio>
===============================================================================================
"""

include { PDB_INTERACTIONS } from '../modules/pdb_interactions.nf'
include { JSON_SCORES } from '../modules/json_scores.nf'
include { MERGE_PDB_SCORES } from '../modules/merge_pdb_scores.nf'

workflow PDB_STATS {
  take:
    extract_coords_script
    overlay_coords_script
    merge_scoring_script
    nlrdomains
    pdb_dir

  main:
    PDB_INTERACTIONS( pdb_dir, 
      nlrdomains.first(),
      extract_coords_script.first(),
      overlay_coords_script.first())

    JSON_SCORES( pdb_dir )

    MERGE_PDB_SCORES( merge_scoring_script,
      PDB_INTERACTIONS.out.ppi_scores.collect(),
      JSON_SCORES.out.pdb_dir_ptms.collect())
}