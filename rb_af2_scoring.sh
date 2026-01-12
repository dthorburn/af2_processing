#!/usr/bin/env bash

export GOOGLE_APPLICATION_CREDENTIALS=

ProjectDir=
cd $ProjectDir

nextflow run rb_af2_scoring.nf \
    -c rb_af2_scoring.config \
    --Mode "pdbstats" \
    --runname "example_name" \
    --PS_input "path to local or GCP directory" \
    --PS_output "path to local or GCP directory" \
    --PS_nlrt_domains "path to specieis specific *_nlrt_domains.tsv (PATHOGEN output)" 