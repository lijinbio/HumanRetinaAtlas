#!/usr/bin/env python3
# vim: set noexpandtab tabstop=2 shiftwidth=2 softtabstop=-1 fileencoding=utf-8:

import sys
import scanpy as sc
import seaborn as sns

if infile.endswith('.h5ad'):
	x=sc.read(infile)
else:
	print(f'Error: format is not supported for {infile}')
	sys.exit(-1)

if any(k not in x.obsm for k in ['X_scVI', 'X_umap']):
	print(f'Error: X_scVI and/or X_umap is not found. See `scrnascvih5ad.sh`')
	sys.exit(-1)

sc.pp.neighbors(x, use_rep='X_scVI', random_state=seed)
# sc.tl.umap(x, random_state=seed) # Skip re-computing umap and assume x.obsm['X_umap']

for level, reslevel in enumerate(resolution):
	key=f'leiden_{level}'
	if level==0:
		sc.tl.leiden(x, resolution=reslevel, random_state=seed, key_added=key)
		x.obs[key]=x.obs[key].astype('str')
	else:
		key_prev=f'leiden_{level-1}'
		for cluster in sorted(x.obs[key_prev].unique()):
			xx=x[x.obs[key_prev]==cluster].copy()
			sc.tl.leiden(xx, resolution=reslevel, random_state=seed, key_added=key)
			xx.obs[key]=xx.obs[key].astype('str')
			x.obs.loc[xx.obs.index, key]=cluster+'.'+xx.obs[key]

sc.set_figure_params(dpi_save=500, figsize=(5, 5))
keys=[k for k in x.obs.columns if k.startswith('leiden_')]
for key in keys:
	ncolor=len(x.obs[key].value_counts())
	if ncolor<100:
		sc.pl.umap(x, color=key, frameon=False, show=False, save=f'{bname}_umap_{key}_wolabel.png')
		sc.pl.umap(x, color=key, frameon=False, show=False, save=f'{bname}_umap_{key}_ondata.png'
			, legend_loc='on data', legend_fontsize='xx-small', legend_fontweight='normal'
			)
	else:
		sc.set_figure_params(dpi_save=150, figsize=(5, 5))
		palette=sns.husl_palette(ncolor)
		sc.pl.umap(x, color=key, palette=palette, frameon=False, show=False, save=f'{bname}_umap_{key}_wolabel.png')
		sc.pl.umap(x, color=key, palette=palette, frameon=False, show=False, save=f'{bname}_umap_{key}_ondata.png') ## duplicate for a consistent two images

x.obs['barcode']=x.obs.index
x.obs.to_csv(f'{bname}_obs.txt.gz', sep='\t', index=False)
