#!/usr/bin/env python3
# vim: set noexpandtab tabstop=2 shiftwidth=2 softtabstop=-1 fileencoding=utf-8:

import os
import sys
import pandas as pd
from exeBash.exeBash import exeBash
from pathlib import Path
import click
import random
import socket

CONTEXT_SETTINGS=dict(help_option_names=['-h', '--help'])
@click.command(context_settings=CONTEXT_SETTINGS)
@click.option('-d', '--outdir', type=click.Path(), default='.', show_default=True, help='Outdir.')
@click.option('-b', '--bname', type=click.STRING, required=True, help='Bname.')
@click.option('-e', '--condaenv', type=click.STRING, help='Conda environment.')
@click.option('-s', '--seed', type=click.INT, default=30, show_default=True, help='Number of seeds.')
@click.option('-l', '--label', type=click.STRING, default='celltype', help='Label of input data.')
@click.option('-m', '--ngene', type=click.INT, default=2000, show_default=True, help='The number of macrogenes.')
@click.option('-g', '--gpu', type=click.INT, multiple=True, default=[0], show_default=True, help='GPU devices.')
@click.argument('infile', type=click.Path(exists=True, resolve_path=True))
def main(outdir, bname, condaenv, seed, label, ngene, gpu, infile):
	"""
Run SATURN train for cross-species analysis by multiple seeds.
(TODO:) might be improved to fully support saturntraincrossspecies. E.g., `-k|--batchkey`.

See `saturnmultipleseedtrainbywkfl` which is implemented by Snakemake and parallel in GPU devices.

\b
INFILE is a sample TSV file with three columns: species<TAB>path<TAB>embedding_path. The header names are fixed.
1. `species`: species
2. `path`: .h5ad file path
3. `embedding_path`: protein embeddings

\b
```E.g.,
$ cat fnameinfo.txt
species	path	embedding_path
human	/storage/singlecell/jinli/mwe/SATURNmwe/example/BC/download/scrnah5adsubsetsamplingbykey/scrnah5adduplicateobs/BC.h5ad	/storage/singlecell/jinli/resource/saturn/protein_embeddings/protein_embeddings_export/ESM2/human_embedding.torch
mouse	/storage/singlecell/jinli/mwe/SATURNmwe/example/BC/download/scrnah5adsubsetsamplingbykey/scrnah5adduplicateobs/mm_concat47_inner.h5ad	/storage/singlecell/jinli/resource/saturn/protein_embeddings/protein_embeddings_export/ESM2/mouse_embedding.torch
```

\b
Example:
  slurmtaco.sh -n g01 -m 120G -- saturnmultipleseedtrain -d "$outdir" -b BC_human_mouse -e saturn -l saturn_label -s 30 -g 0 -g 1 -g 2 -g 3 -- fnameinfo.txt

\b
See also:
  Related:
    saturntraincrossspecies
  Depends:
    Github/SATURN

\b
Date: 2023/03/16
Authors: Jin Li <lijin.abc@gmail.com>
	"""
	Path(outdir).mkdir(parents=True, exist_ok=True)
	config=pd.read_csv(infile, sep='\t', header=0)
	config['path']=[Path().absolute() / p for p in config['path']]
	config.to_csv(f"{outdir}/{bname}.csv", index=False)

	absdir=Path(__file__).parent
	scriptname=Path(__file__).stem
	os.chdir(outdir)
	script=f"{absdir}/SATURN/saturn_multiple_seeds.py"
	exprs=[
		f"{script}",
		f"--run '{bname}.csv'",
		f"--seed {seed}",
		f"--gpus {' '.join(map(str, gpu))}",
		f"--macrogenes {ngene}",
		f"--in_label_col '{label}'",
		f"--ref_label_col '{label}'",
		]
	return exeBash.callback(exprs, condaenv=condaenv, verbose=True)

if __name__ == "__main__":
	sys.exit(main())
