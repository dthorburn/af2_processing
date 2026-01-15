#!/usr/bin/env nextflow

process PDB_INTERACTIONS {
  maxForks params.PI_forks
  maxRetries params.PI_retries
  errorStrategy 'retry'

  container 'dthorbur1990/pdb_contacts:latest'
  containerOptions '--shm-size 2g'

  cpus params.PI_cpus
  memory params.PI_memory
  disk params.PI_disk

  publishDir(
    path: "${params.PS_output}/raw",
    mode: 'copy',
  )

  input:
    path(pdb_dir)
    path(extract_coords_script)
//    path(nlrdomains)
//    path(overlay_coords_script)

  output:
    path("ppi_coords_${task.index}.csv")
    path("ppi_scores_${task.index}.csv"), emit: ppi_scores
    //path("nlr_domain_interactions_${task.index}.csv"), emit: ppi_scores // Deprecated due to regex scoring being too restrictive and not uniform enough across species.

  script:
  """
  #ls ./${pdb_dir}/
  python ${extract_coords_script} ./${pdb_dir}/ ppi_coords_${task.index}.csv ppi_scores_${task.index}.csv ${params.PI_ext_args} 
  """
  //  #python ${overlay_coords_script} ppi_coords_${task.index}.csv ppi_scores_${task.index}.csv ${nlrdomains} nlr_domain_interactions_${task.index}.csv --regex_string '${params.PI_regex_string}' ${params.PI_ol_args} 
}