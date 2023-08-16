#!/usr/bin/env python3
# vim: set noexpandtab tabstop=2 shiftwidth=2 softtabstop=-1 fileencoding=utf-8:

import scanpy as sc
import anndata as ad
import pandas as pd
import pickle

with open(weightfile, 'rb') as f:
	macrogene_weights=pickle.load(f)

def get_scores(macrogene):
	'''
	Given the index of a macrogene, return the scores by gene for that centroid
	'''
	scores={}
	for (gene), score in macrogene_weights.items():
		scores[gene]=score[int(macrogene)]
	return scores

x=sc.read(infile)
macrogene_adata=ad.AnnData(X=x.obsm['macrogenes'], obs=x.obs)
sc.tl.rank_genes_groups(macrogene_adata, groupby=key, groups=group, method='wilcoxon')

for g in group:
	xg=sc.get.rank_genes_groups_df(macrogene_adata, group=g).head(ntop)
	xg.to_csv(f"{outdir}/{bname}_{key}_{g}_macrogenes.txt.gz", sep='\t', index=False)
	res=pd.DataFrame()
	for macrogene in xg['names']:
		mres=pd.DataFrame(get_scores(macrogene).items(), columns=['gene', 'weight']).sort_values('weight', ascending=False).head(ngene)
		mres=mres.loc[mres['weight']>=minweight, :]
		mres.insert(loc=0, column='macrogene', value=macrogene)
		res=pd.concat([res, mres], axis=0, join='outer', ignore_index=True)
	res.to_csv(f"{outdir}/{bname}_{key}_{g}_genes.txt.gz", sep='\t', index=False)
