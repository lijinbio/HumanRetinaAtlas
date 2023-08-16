import yaml
import subprocess
from pathlib import Path
import numpy as np

# Parameters
infile, outdir, bname, nowtimestr=config['infile'].split(','), config['outdir'], config['bname'].split(','), config['nowtimestr']
config['infile'], config['bname']=infile, bname
files=dict(zip(bname, infile))

# for rules using a function
def get_file(wildcards):
	return files[wildcards.name]

if config['condaenv']=='None':
	config['condaenv']=None


if 'saturntraincrossspecies' not in config:
	config['saturntraincrossspecies']={
		'label': 'saturn_label',
		'batchkey': 'batch_label',
		'condaenv': config['condaenv'],
		'ngene': 5000,
		'nhvg': 8000,
		'hvgspan': 1.0,
		'mapfile': None,
		'epoch': 50,
		'gpu': [0, 1],
		'nseed': 30,
	}
if config['condaenv']: # set a higher priority for the option
	config['saturntraincrossspecies']['condaenv']=config['condaenv']

if 'nseed' in config['saturntraincrossspecies'] and config['saturntraincrossspecies']['nseed']>0:
	saturnseed=list(42+np.arange(config['saturntraincrossspecies']['nseed']))
else:
	saturnseed=[42]

saturntraincrossspecies_cmd=[
	f"saturntraincrossspecies",
	f"-l {config['saturntraincrossspecies']['label']}",
	f"-k {config['saturntraincrossspecies']['batchkey']}",
	f"-m {config['saturntraincrossspecies']['ngene']}",
	f"-n {config['saturntraincrossspecies']['nhvg']}",
	f"-v {config['saturntraincrossspecies']['hvgspan']}",
	f"-p {config['saturntraincrossspecies']['epoch']}",
	]
if config['saturntraincrossspecies']['condaenv']:
	saturntraincrossspecies_cmd+=[f"-e {config['saturntraincrossspecies']['condaenv']}"]
if config['saturntraincrossspecies']['mapfile']:
	saturntraincrossspecies_cmd+=[f"-f {config['saturntraincrossspecies']['mapfile']}"]
saturntraincrossspecies_cmd=' '.join(saturntraincrossspecies_cmd)


if 'saturntrainh5ad2umap' not in config:
	config['saturntrainh5ad2umap']={
		'condaenv': config['condaenv'],
		'label': ['batch_labels', 'labels', 'labels2', 'ref_labels', 'species'],
		'seed': 12345,
		'resolution': 0.5,
		'neighbor': 15,
		'npc': None,
	}
if config['condaenv']:
	config['saturntrainh5ad2umap']['condaenv']=config['condaenv']

saturntrainh5ad2umap_cmd=[
	f"saturntrainh5ad2umap",
	f"-s {config['saturntrainh5ad2umap']['seed']}",
	f"-r {config['saturntrainh5ad2umap']['resolution']}",
	f"-n {config['saturntrainh5ad2umap']['neighbor']}",
	]
if config['saturntrainh5ad2umap']['condaenv']:
	saturntrainh5ad2umap_cmd+=[f"-e {config['saturntrainh5ad2umap']['condaenv']}"]
if config['saturntrainh5ad2umap']['npc']:
	saturntrainh5ad2umap_cmd+=[f"-p"]
if 'label' in config['saturntrainh5ad2umap'] and len(config['saturntrainh5ad2umap']['label'])>0:
	saturntrainh5ad2umap_cmd+=[f"-l {s}" for s in config['saturntrainh5ad2umap']['label']]
saturntrainh5ad2umap_cmd=' '.join(saturntrainh5ad2umap_cmd)


if 'saturnh5adumap2seuratdimplotsplitby' not in config:
	config['saturnh5adumap2seuratdimplotsplitby']={
		'condaenv': config['condaenv'],
		'group': ['labels', 'labels2', 'ref_labels'],
		'split': 'species',
		'height': 6,
		'width': 6,
		'legendwidth': 4,
	}
if config['condaenv']:
	config['saturnh5adumap2seuratdimplotsplitby']['condaenv']=config['condaenv']

saturnh5adumap2seuratdimplotsplitby_cmd=[
	f"saturnh5adumap2seuratdimplotsplitby",
	f"-s {config['saturnh5adumap2seuratdimplotsplitby']['split']}",
	f"-H {config['saturnh5adumap2seuratdimplotsplitby']['height']}",
	f"-W {config['saturnh5adumap2seuratdimplotsplitby']['width']}",
	f"-L {config['saturnh5adumap2seuratdimplotsplitby']['legendwidth']}",
	]
if config['saturnh5adumap2seuratdimplotsplitby']['condaenv']:
	saturnh5adumap2seuratdimplotsplitby_cmd+=[f"-e {config['saturnh5adumap2seuratdimplotsplitby']['condaenv']}"]
if 'group' in config['saturnh5adumap2seuratdimplotsplitby'] and len(config['saturnh5adumap2seuratdimplotsplitby']['group'])>0:
	saturnh5adumap2seuratdimplotsplitby_cmd+=[f"-g {g}" for g in config['saturnh5adumap2seuratdimplotsplitby']['group']]
saturnh5adumap2seuratdimplotsplitby_cmd=' '.join(saturnh5adumap2seuratdimplotsplitby_cmd)



if 'saturnh5adumap2seuratclustree' not in config:
	config['saturnh5adumap2seuratclustree']={
		'condaenv': config['condaenv'],
		'group': 'labels',
		'color': 'species',
		'reorder': 'F',
		'numericorder': 'F',
		'height': 7.5,
		'width': 6,
	}
if config['condaenv']:
	config['saturnh5adumap2seuratclustree']['condaenv']=config['condaenv']

saturnh5adumap2seuratclustree_cmd=[
	f"saturnh5adumap2seuratclustree",
	f"-g {config['saturnh5adumap2seuratclustree']['group']}",
	f"-c {config['saturnh5adumap2seuratclustree']['color']}",
	f"-r {config['saturnh5adumap2seuratclustree']['reorder']}",
	f"-n {config['saturnh5adumap2seuratclustree']['numericorder']}",
	f"-H {config['saturnh5adumap2seuratclustree']['height']}",
	f"-W {config['saturnh5adumap2seuratclustree']['width']}",
	]
if config['saturnh5adumap2seuratclustree']['condaenv']:
	saturnh5adumap2seuratclustree_cmd+=[f"-e {config['saturnh5adumap2seuratclustree']['condaenv']}"]
saturnh5adumap2seuratclustree_cmd=' '.join(saturnh5adumap2seuratclustree_cmd)


# debug parameters
with open(f"config_{nowtimestr}.yaml", 'w') as f:
	yaml.dump(config, f, sort_keys=False)
