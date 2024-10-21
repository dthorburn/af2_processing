export GOOGLE_APPLICATION_CREDENTIALS=/home/dthorbur/rb-main.json

ProjectDir=/home/dthorbur/Resurrect_Bio/Scripts/af2_processing
cd $ProjectDir

nextflow run rb_af2_scoring.nf \
    -c rb_af2_scoring.config \
    --Mode "pdbstats" \
    --PS_input "gs://florafold/03-screens/asr_working_nlrs/batch1/predictions" \
    --PS_output "./testing" \
    --PS_nlrt_domains "/home/dthorbur/Resurrect_Bio/Scripts/rb_automation/af2_scoring/test_data/Glycine_max_nlrt_domains.tsv"
