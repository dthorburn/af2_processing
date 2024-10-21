#!/usr/bin/env nextflow

process JSON_SCORES {
  maxForks params.JS_forks
  maxRetries params.JS_retries
  container 'dthorbur1990/rb_assesscontacts:latest'
  containerOptions '--shm-size 2g'
  errorStrategy 'retry'

  cpus params.JS_cpus
  memory params.JS_memory
  disk params.JS_disk

  publishDir(
    path: "${params.PS_output}/raw",
    mode: 'copy',
  )

  input:
    path(input_dir)

  output:
    path("output_ptms_${task.index}.csv"), emit: pdb_dir_ptms

  script:
  """
  entry_dir=\$(pwd)
  cd \${entry_dir}/${input_dir}

  grep -o "ptm.*" *.json | sed "s/_scores//" | sed "s/_alphafold2.*json.ptm.. /,/" | sed "s/.*\\///" | sed "s/ .iptm...//" | sed "s/}//" >> \${entry_dir}/output_ptms_${task.index}.csv
  cd \${entry_dir}
  """
}