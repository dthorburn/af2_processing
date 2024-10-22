#!/usr/bin/env nextflow

/*
 *
 * Alphafold2-Multimer Scoring cloud Nextflow Solution.
 *
 * Author: Miles <miles@resurrect.bio>
 * Date created: 21/10/2024
 *
 */

 def helpMessage() {
log.info """
Resurrect Bio Alphafold2-Multimer Scoring was developed to help score PPI interactions in AF2 PDBs in a
high-throughput manner by utilising parallelisation on GCP|AWS. 

Setup:
1. Set up a google cloud bucket. If you are using spry-connection-368822 project, ensure the buckets 
   are in the same region as compute environments.
2. Set up correct cloud computing login credential.
3. Choose the pipeline mode for the data: pdbstats.
4. Update the required and optional arguments.
5. Submit pipeline coordinator using 'bash rb_af2_scoring.sh'.

All docker images are maintained by Miles <miles@resurrect.bio>. If there are any issues please contact
me. 

Required arguments per workflow:
  --mode                        Mode of operation [pdbstats]
  --PS_input

Optional arguments:
  --help                        Show this message.
  --runname                     Name the output file for PDB_STATS

  --PI_cpus                     Number of cpus for PDB_INTERACTIONS [default: 4]
  --PI_memory                   Size of VM memory for PDB_INTERACTIONS [default: '64 GB']
  --PI_disk                     Size of VM disk for PDB_INTERACTIONS [default: '40 GB']
  --PI_ext_args                 Additional arguments for extract_pdb_coords.py script
  --PI_ol_args                  Additional arguments for overlay_pdb_coords.py script

  --JS_cpus                     Number of cpus for JSON_SCORES [default: 4]
  --JS_memory                   Size of VM memory for JSON_SCORES [default: '32 GB']
  --JS_disk                     Size of VM disk for JSON_SCORES [default: '40 GB']

  --MP_cpus                     Number of cpus for MERGE_PDB_SCORES [default: 2]
  --MP_memory                   Size of VM memory for MERGE_PDB_SCORES [default: '16 GB']
  --MP_disk                     Size of VM disk for MERGE_PDB_SCORES [default: '40 GB']
  --MP_ext_args                  Additional arguments for merge_pdb_stats.py script
"""
}

if (params.help) {
    helpMessage()
    exit 0
}

if( params.Mode == "pdbstats" ){
  include { PDB_STATS }  from './workflows/postprocessing'
}

workflow {
                                                                // ==============================
                                                                //   Mode: Batch PDB Processing 
                                                                // ==============================
  if( params.Mode == "pdbstats" ){
      //.fromPath("${params.PS_input}/batch*", type: 'dir')
      //.buffer( size: params.PS_pdbs_per_channel, remainder: true)
    Channel
      .fromPath("${params.PS_input}/${params.PS_batch_name}*", type: 'dir')
      .ifEmpty { error "No PDBs in input directory: ${params.PS_input}/${params.PS_batch_name}*" }
      .set { pdb_dir }
    Channel
      .fromPath(params.PS_nlrt_domains)
      .ifEmpty { error "No NLR domains tsv supplied: ${params.PS_nlrt_domains}" }
      .set { nlrdomains }
    Channel
      .fromPath(params.extract_coords_script)
      .ifEmpty { error "No merging Rscript supplied: ${params.extract_coords_script}" }
      .set { extract_coords_script }
    Channel
      .fromPath(params.overlay_coords_script)
      .ifEmpty { error "No merging Rscript supplied: ${params.overlay_coords_script}" }
      .set { overlay_coords_script }
    Channel
      .fromPath(params.merge_scoring_script)
      .ifEmpty { error "No merging Rscript supplied: ${params.merge_scoring_script}" }
      .set { merge_scoring_script }

    //pdb_dir.view()

    PDB_STATS(extract_coords_script, overlay_coords_script, merge_scoring_script, nlrdomains, pdb_dir)
  }
}