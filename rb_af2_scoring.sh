#!/usr/bin/env bash

export GOOGLE_APPLICATION_CREDENTIALS=/home/dthorbur/rb-main.json

ProjectDir=/home/dthorbur/Resurrect_Bio/Projects/04_FloraFold/05_screen/af2_processing
cd $ProjectDir

nextflow run rb_af2_scoring.nf \
    -c rb_af2_scoring.config \
    --Mode "pdbstats" \
    --runname "hvulgare_rerun" \
    --PS_input "gs://rb-interactions/hvulgare-bgraminis/florafold_rerun/predictions" \
    --PS_output "/home/dthorbur/Resurrect_Bio/Projects/01_Candidate_Search/03_Interactions/07_hvulgare_bgraminis/florafold_rerun" \
    --PS_nlrt_domains "/home/dthorbur/Resurrect_Bio/Scripts/rb_automation/af2_scoring/test_data/Glycine_max_nlrt_domains.tsv" \
    --PI_regex_string '([A-Z0-9]+)_(EGZ[0-9]+)_(OG[0-9]+)_([0-9]+)'
