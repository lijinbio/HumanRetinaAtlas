#!/usr/bin/env python3
# vim: set noexpandtab tabstop=2 shiftwidth=2 softtabstop=-1 fileencoding=utf-8:

import os
import sys
from exePython.exePython import exePython
from pathlib import Path
import click
CONTEXT_SETTINGS=dict(help_option_names=['-h', '--help'])
@click.command(context_settings=CONTEXT_SETTINGS)
@click.option('-d', '--outdir', type=click.Path(), default='.', show_default=True, help='Outdir.')
@click.option('-b', '--bname', type=click.STRING, required=True, help='Bname.')
@click.option('-e', '--condaenv', type=click.STRING, help='Conda environment.')
@click.option('-r', '--resolution', multiple=True, type=click.FLOAT, help='Resolution for leiden clustering.')
@click.option('-s', '--seed', type=click.INT, required=False, default=12345, show_default=True, help='Random seed.')
@click.argument('infile', type=click.Path(exists=True, resolve_path=True))
def main(outdir, bname, condaenv, resolution, seed, infile):
	"""
Generate a nested leiden clustering using x.obsm['X_scVI']. Levels use resolutions by `-r|--resolution`. This is different from `scrnascvimodel2leidensbyresolution` where low-representation is loaded from model.

INFILE is a scVI object file (.h5ad). `x.obsm['X_scVI']` is assumed.

\b
Example:
  indir=$(mrrdir.sh ..)
  outdir=$(mrrdir.sh)
  function cmd {
  local f=$1
  local bname=$(basename "$f" .h5ad)
  if fileexists.sh "$f"
  then
  	slurmtaco.sh -m 20G -- scrnah5adscvi2leidensbyresolution -e scvi_gpu -d "$outdir" -b "$bname" -r 0.2 -r 0.1 -r 0.1 -- "$f"
  fi
  }
  source env_parallel.bash
  env_parallel -j 3 cmd ::: "$indir"/*.h5ad

\b
See also:
  Related:
    scrnascvimodel2leidensbylevel
    scrnascvimodel2leidensbyresolution
  Depends:
    Python/scVI

\b
Date: 2022/12/09
Authors: Jin Li <lijin.abc@gmail.com>
	"""
	Path(outdir).mkdir(parents=True, exist_ok=True)
	absdir=Path(__file__).parent
	scriptname=Path(__file__).stem
	script=f'{absdir}/python/{scriptname}.py'
	exprs=[
		f"bname='{bname}'",
		f"resolution={resolution}",
		f"seed={seed}",
		f"infile='{infile}'",
		]
	os.chdir(outdir)
	return exePython.callback(exprs, script=script, condaenv=condaenv, verbose=True)

if __name__ == "__main__":
	sys.exit(main())
