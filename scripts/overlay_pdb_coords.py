import os
import re
import argparse
import numpy as np
import pandas as pd

## Initial solution will ONLY count interactions with NBD, LRR, and between those to handle unannotated WHD domains. 
#def sum_domain_interations(seq, model, coords, domains, whd_width = 100):
def sum_domain_interations(file, coords, domains, whd_width = 100):
	## Iterate through seqnames and summarise the number of interactions per domain 
	## Getting the unique names from the seqname column 
	output_table = []
	temp_coords  = coords.loc[coords['file'] == file]
	seq = temp_coords.seqname.unique()[0]
	temp_domains = domains.loc[domains['seqname'] == seq]
	nbd_coords = temp_domains.loc[temp_domains['description'] == "NBARC"]
	lrr_coords = temp_domains.loc[temp_domains['description'] == "LRR"]
	## Handling cases of multiple LRR domains being present and edge cases if more NDBs are present. 
	if len(nbd_coords) > 1:
		nbd_start = nbd_coords['start'].iloc[0]
		nbd_end   = nbd_coords['end'].iloc[-1]
	else:
		nbd_start = nbd_coords['start'].iloc[0]
		nbd_end   = nbd_coords['end'].iloc[0]
	if len(lrr_coords) > 1:
		lrr_start = lrr_coords['start'].iloc[0]
		lrr_end   = lrr_coords['end'].iloc[-1]
	else:
		lrr_start = lrr_coords['start'].iloc[0]
		lrr_end   = lrr_coords['end'].iloc[0]
	## Sanity check
	overlapping_nbd_lrr = "yes" if nbd_end > lrr_start else "no"
	output_table.append({
		"seqname": seq,
		"model": temp_coords.model.unique()[0],
		#"gene_id": temp_coords.gene_id.values[0],
		"effector": temp_coords.effector.values[0],
		"complex": temp_coords.complex.values[0],
		"domains": temp_domains.Domain.values[0],
		"overlapping_nbd_lrr": overlapping_nbd_lrr,
		"pre_nbd_contacts": temp_coords['residue1_num'][temp_coords['residue1_num'] < nbd_start].count(),
		"nbd_contacts": temp_coords['residue1_num'].between(nbd_start, nbd_end).sum(),
		"nbd_end_contacts": temp_coords['residue1_num'].between(nbd_end-whd_width, nbd_end).sum(),
		"between_ndb_lrr_contacts": temp_coords['residue1_num'].between(nbd_end, lrr_start).sum(),
		"lrr_contacts": temp_coords['residue1_num'].between(lrr_start, lrr_end).sum(),
		"post_lrr_contacts": temp_coords['residue1_num'][temp_coords['residue1_num'] > lrr_end].count(),
	})
	if output_table:
		res = pd.DataFrame(output_table)
		return(res)

parser = argparse.ArgumentParser(description="Find overlap between PDB interaction coords and NLR domains.")
# Positional arguments for the PDB directory and output files
parser.add_argument("ppi_coord_file", type=str, help="Path to extract_pdb_coords.py output coord csv")
parser.add_argument("ppi_scores_file", type=str, help="Path to extract_pdb_coords.py output score csv")
parser.add_argument("nlr_domain_file", type=str, help="Path to PLANT x_nlrt_domains.tsv file")
parser.add_argument("output_file", type=str, help="Path for output CSV")
# Optional arguments for minimum and maximum distance thresholds
parser.add_argument("--regex_string", type=str, default=r'([A-Z0-9]+)_(EGZ[0-9]+)_(OG[0-9]+)_([0-9]+)', 
	help="Regex string to parse complex name column")
parser.add_argument("--whd_width", type=int, default=100, help="AA width of WHD domains")
args = parser.parse_args()

## testing
#ppi_coord_file  = os.path.abspath("/home/dthorbur/Resurrect_Bio/Projects/04_FloraFold/05_screen/af2_processing/data/test_data/interactions.csv")
#ppi_scores_file  = os.path.abspath("/home/dthorbur/Resurrect_Bio/Projects/04_FloraFold/05_screen/af2_processing/data/test_data/scoring.csv")
#nlr_domain_file = os.path.abspath("/home/dthorbur/Resurrect_Bio/Scripts/rb_automation/af2_scoring/test_data/Glycine_max_nlrt_domains.tsv")
#regex_string = '([A-Z0-9]+)_(EGZ[0-9]+)_(OG[0-9]+)_([0-9]+)'

ppi_coord_file  = os.path.abspath(args.ppi_coord_file)
ppi_scores_file  = os.path.abspath(args.ppi_scores_file)
nlr_domain_file = os.path.abspath(args.nlr_domain_file)
output_file = os.path.abspath(args.output_file)
regex_string = args.regex_string


## Reading in data
coords  = pd.read_csv(ppi_coord_file)
scores  = pd.read_csv(ppi_scores_file)
domains = pd.read_csv(nlr_domain_file, sep='\t', usecols=[0, 2, 3, 4, 5])

## adding appropraite columns and subsetting
#coords['gene_id'] = coords['complex'].apply(lambda seqname: re.match(regex_string, seqname).group(1))
#coords['seqname'] = coords['complex'].apply(lambda seqname: re.match(regex_string, seqname).group(2))
#coords['effector'] = coords['complex'].apply(lambda seqname: re.match(regex_string, seqname).group(3))
#coords['complex_len'] = coords['complex'].apply(lambda seqname: re.match(regex_string, seqname).group(5))

#coords['gene_id'] = coords['complex'].str.extract(regex_string, expand=False)[0]
coords['seqname'] = coords['complex'].str.extract(regex_string, expand=False)[0]
coords['effector'] = coords['complex'].str.extract(regex_string, expand=False)[1]
coords['complex_len'] = coords['complex'].str.extract(regex_string, expand=False)[3]
print(coords)
domains = domains.loc[domains['description'] != 'chain']

all_output = []
uniq_complexes = set(coords.file)
total_samples = len(uniq_complexes) 
for idx, temp_complex in enumerate(uniq_complexes, start = 1):
	print(f"Processing file {idx}/{total_samples}: {temp_complex}")
	temp_coords = coords[coords['file'] == temp_complex]
	#uniq_models = set(coords.model)
	#for temp_model in uniq_models:
	#	temp_model_df = temp_coords[temp_coords['model'] == temp_model]
	#	output_df = sum_domain_interations(temp_model_df.seqname.unique()[0], temp_model, temp_model_df, domains)
	#	all_output.append(output_df)
	output_df = sum_domain_interations(temp_coords.file.unique()[0], temp_coords, domains)
	all_output.append(output_df)

if all_output:
	combined_df = pd.concat(all_output, ignore_index=True)
	merged_df = combined_df.merge(scores, on=['complex', 'model'])
	print(merged_df)
	merged_df.to_csv(output_file, index=False)
else:
	print("ERROR: No output df generated.")
