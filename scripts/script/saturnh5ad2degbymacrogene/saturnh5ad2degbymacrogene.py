#!/usr/bin/env python3
# vim: set noexpandtab tabstop=2 shiftwidth=2 softtabstop=-1 fileencoding=utf-8:

import os
import sys
from exePython.exePython import exePython
from pathlib import Path
import random
import socket
import click

CONTEXT_SETTINGS=dict(help_option_names=['-h', '--help'])
@click.command(context_settings=CONTEXT_SETTINGS)
@click.option('-d', '--outdir', type=click.Path(resolve_path=True), default='.', show_default=True, help='Outdir.')
@click.option('-b', '--bname', type=click.STRING, required=True, help='Bname.')
@click.option('-e', '--condaenv', type=click.STRING, help='Conda environment.')
@click.option('-k', '--key', type=click.STRING, required=True, help='Key for groups.')
@click.option('-g', '--group', type=click.STRING, multiple=True, required=True, help='Group[s] for DEGs.')
@click.option('-w', '--weightfile', type=click.Path(exists=True, resolve_path=True), required=True, help='SATURN weight file.')
@click.option('-n', '--ntop', type=click.INT, default=20, show_default=True, help='Top n macrogenes.')
@click.option('-m', '--ngene', type=click.INT, default=100, show_default=True, help='Top m genes per macrogene.')
@click.option('-t', '--minweight', type=click.FLOAT, default=0.1, show_default=True, help='Gene weight threshold per macrogene.')
@click.argument('infile', type=click.Path(exists=True, resolve_path=True))
def main(outdir, bname, condaenv, key, group, weightfile, ntop, ngene, minweight, infile):
	"""
Perform differential gene expression analysis on macrogenes.

INFILE is the trained SATURN object file (.h5ad).

\b
Example:
  indir=/storage/singlecell/jinli/wkfl/atlashumanprj/integration/snRNA/cross_species/saturncrossspecieswkfl/BC/s2k/n5k/saturntraincrossspecies/BC_mouse_macaque/saturn_results/
  weightfile=$indir/test256_data_human_macaque_mouse_org_saturn_seed_12345_genes_to_macrogenes.pkl
  infile=$indir/test256_data_human_macaque_mouse_org_saturn_seed_12345.h5ad
  outdir=$(mrrdir.sh)
  bname=BC_HBC9_HBC14
  saturnh5ad2degbymacrogene -d "$outdir" -b "$bname" -e h5ad08 -k labels -g human_HBC9 -g human_HBC14 -w "$weightfile" -- "$infile"

\b
See also:
  Upstream:
    saturntraincrossspecies
  Depends:
    Github/SATURN

\b
Date: 2023/03/24
Authors: Jin Li <lijin.abc@gmail.com>
	"""
	absdir=Path(__file__).parent
	scriptname=Path(__file__).stem
	script=f'{absdir}/python/{scriptname}.py'
	exprs=[
		f"outdir='{outdir}'",
		f"bname='{bname}'",
		f"weightfile='{weightfile}'",
		f"key='{key}'",
		f"group={group}",
		f"ntop={ntop}",
		f"ngene={ngene}",
		f"minweight={minweight}",
		f"infile='{infile}'",
		]
	Path(outdir).mkdir(parents=True, exist_ok=True)
	# os.chdir(outdir)
	return exePython.callback(exprs, script=script, condaenv=condaenv, verbose=True)

if __name__ == "__main__":
	sys.exit(main())
