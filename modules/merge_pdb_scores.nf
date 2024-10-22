#!/usr/bin/env nextflow

process MERGE_PDB_SCORES {
  maxForks params.MP_forks
  maxRetries params.MP_retries
  errorStrategy 'retry'

  container 'dthorbur1990/pdb_contacts:latest'
  containerOptions '--shm-size 2g'

  cpus params.MP_cpus
  memory params.MP_memory
  disk params.MP_disk

  publishDir(
    path: "${params.PS_output}",
    mode: 'copy',
  )

  input:
    path(merge_scoring_script)
    path(ppi_scores)
    path(ptm_scores)

  output:
    path("*.csv"), emit: ppi_scores

  script:
  //def merge_ppi = ppi_scores.collect{ "cat $it | sed 1,1d >> ./all_dists.csv" }.join('\n')
  //def merge_ptm = ptm_scores.collect{ "cat $it >> ./all_iptms.csv" }.join('\n')
  """
  ls ./
  if [ -z ${params.runname} ]
  then
    out_file="summary_results_\$(date +\"%d-%m-%Y\").csv"
  else
    out_file="${params.runname}_\$(date +"%d-%m-%Y\").csv"
  fi

  python ${merge_scoring_script} `pwd`/ `pwd`/ \${out_file} ${params.MP_ext_args} 
  """
}
