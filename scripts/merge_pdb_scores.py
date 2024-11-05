import os
import re
import sys
import glob
import argparse
import pandas as pd

parser = argparse.ArgumentParser(description="Merge JSON and PSB scores into single file")
parser.add_argument("pdb_csv_dir",  type=str, help="Path to PDB_INTERACTIONS main output csv directory")
parser.add_argument("json_csv_dir", type=str, help="Path to JSON_SCORES csv directory")
parser.add_argument("scoring_output", type=str, help="Path for output CSV")
args = parser.parse_args()

## Testing
#pdb_csv_dir = os.path.abspath("/home/dthorbur/Resurrect_Bio/Scripts/af2_processing/testing/raw/")
#json_csv_dir = os.path.abspath("/home/dthorbur/Resurrect_Bio/Scripts/af2_processing/testing/raw/")
#scoring_output = os.path.abspath("/home/dthorbur/Resurrect_Bio/Scripts/af2_processing/testing/raw/merged_output.csv")

pdb_csv_dir = os.path.abspath(args.pdb_csv_dir)
json_csv_dir = os.path.abspath(args.json_csv_dir)
scoring_output = os.path.abspath(args.scoring_output)

## Reading in all the data and concatanating into a single file
all_pdb_csv = []
for idx, pdb_csv in enumerate(glob.glob(f"{pdb_csv_dir}/nlr_domain_interactions*.csv"), start = 1):
	print(f"Processing file {idx}: {pdb_csv}")
	temp_csv = pd.read_csv(pdb_csv)
	all_pdb_csv.append(temp_csv)
	#del temp_csv

if all_pdb_csv:
	all_pdb_csv = pd.concat(all_pdb_csv, ignore_index = True)

all_json_csv = []
for idx, json_csv in enumerate(glob.glob(f"{json_csv_dir}/output_ptms*.csv"), start = 1):
	print(f"Processing file {idx}: {json_csv}")
	temp_csv = pd.read_csv(json_csv, header=None, names=['complex_wrank', 'pTM', 'ipTM'])
	temp_csv['complex'] = temp_csv['complex_wrank'].str.replace(r'_rank.*', '', regex = True)
	temp_csv['rank'] = temp_csv['complex_wrank'].str.extract(r'(rank_0.*)')
	temp_csv = temp_csv.drop('complex_wrank', axis = 1)
	all_json_csv.append(temp_csv)

if all_json_csv:
	all_json_csv = pd.concat(all_json_csv, ignore_index = True)


merged_df = all_json_csv.merge(all_pdb_csv.rename(columns={"model": "rank"}), on=['complex' , 'rank'])
merged_df = merged_df.reindex(columns=['complex', 'rank', 'seqname', 'gene_id', 'effector', 'domains', 'overlapping_nbd_lrr', 'pre_nbd_contacts', 'nbd_contacts', 'nbd_end_contacts', 
			'between_ndb_lrr_contacts', 'lrr_contacts', 'post_lrr_contacts', 'close_atoms', 'close_residues', 'min_distance_threshold', 'pTM', 'ipTM', 'pdockq', 
			'pdockq_confidence', 'chain_A_plddt_mean', 'chain_A_plddt_sd', 'chain_B_plddt_mean', 'chain_B_plddt_sd'])
print(merged_df)
merged_df.to_csv(scoring_output, index=False)

