#!/usr/bin/env python3
# vim: set noexpandtab tabstop=2 shiftwidth=2 softtabstop=-1 fileencoding=utf-8:

import os
import sys
from exeR.exeR import exeR
from pathlib import Path
import click

CONTEXT_SETTINGS=dict(help_option_names=['-h', '--help'])
@click.command(context_settings=CONTEXT_SETTINGS)
@click.option('-d', '--outdir', type=click.Path(resolve_path=True), default='.', show_default=True, help='Outdir.')
@click.option('-b', '--bname', type=click.STRING, required=True, help='Bname.')
@click.option('-e', '--condaenv', type=click.STRING, help='Conda environment.')
@click.option('-g', '--group', type=click.STRING, default='labels', show_default=True, help='Group for clusters.')
@click.option('-c', '--color', type=click.STRING, default='species', show_default=True, help='Color label.')
@click.option('-H', '--height', type=click.FLOAT, default=7.5, show_default=True, help='Height.')
@click.option('-W', '--width', type=click.FLOAT, default=6, show_default=True, help='Width.')
@click.option('-m', '--method', type=click.Choice(['complete', 'average']), is_flag=False, flag_value='complete', default='average', show_default=True, help='Agglomeration method.')
@click.option('-u', '--uhang', type=click.FLOAT, default=0.1, show_default=True, help='Hang for hclust.')
@click.argument('infile', type=click.Path(exists=True, resolve_path=True))
def main(outdir, bname, condaenv, group, color, height, width, method, uhang, infile):
	"""
Build and plot a phylogenetic tree using SATURN low-embedding for cross-species. This will customize the running steps without using Seurat::BuildClusterTree().

INFILE is a .h5ad file.

\b
Example:
  f=/storage/singlecell/jinli/wkfl/atlashumanprj/integration/snRNA/cross_species/saturncrossspecieswkfl/BC/s2k/n5k/saturntrainh5ad2umap/BC_mouse_macaque/BC_mouse_macaque.h5ad
  outdir=$(mrrdir.sh)
  bname=$(basename "$f" .h5ad)
  slurmtaco.sh -t 2 -m 20G -- saturnh5adexpr2hclust -d "$outdir" -b "$bname" -e saturn -g labels -c species -- "$f"

\b
See also:
  Related:
    saturnh5adumap2seuratclustree
    scrnah5adexpr2hclust
  Depends:
    R/rhdf5
    R/Seurat

\b
Date: 2023/03/22
Authors: Jin Li <lijin.abc@gmail.com>
	"""
	absdir=Path(__file__).parent
	scriptname=Path(__file__).stem
	script=f'{absdir}/R/{scriptname}.R'
	exprs=[
		f"outdir='{outdir}'",
		f"bname='{bname}'",
		f"group='{group}'",
		f"color='{color}'",
		f"height={height}",
		f"width={width}",
		f"method='{method}'",
		f"uhang={uhang}",
		f"infile='{infile}'",
		]
	Path(outdir).mkdir(parents=True, exist_ok=True)
	# os.chdir(outdir)
	return exeR.callback(exprs, script=script, condaenv=condaenv, verbose=True)

if __name__ == "__main__":
	sys.exit(main())
