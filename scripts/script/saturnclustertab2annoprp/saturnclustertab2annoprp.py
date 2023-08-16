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
@click.option('-s', '--skipcol', type=click.INT, default=1, show_default=True, help='Skip columns.')
@click.option('-p', '--percent', type=click.FLOAT, default=0.1, show_default=True, help='Minimum percentage for a label.')
@click.argument('infile', type=click.Path(exists=True, resolve_path=True))
def main(outdir, bname, condaenv, skipcol, percent, infile):
	"""
To calculate the composition proportions from cluster mapping. This is useful for SATURN subclass annotation.

INFILE is a .txt.gz mapping file.

\b
Example:
  f=$(parentsearch.sh -d test_data/saturnclustertab2annoprp AC_scRNA2snRNA_snRNA_scRNA_LogisticRegression_0.9_cluster2_predict.txt.gz)
  bname=$(basename "$f" .txt.gz)
  outdir=$(mktemp -d -u)
  saturnclustertab2annoprp -d "$outdir" -b "$bname" -- "$f"

\b
See also:
  Upstream:
    saturncntclassifierpred2tab
  Related:
    scrnaclusterlabel2annotation.sh

\b
Date: 2023/05/16
Authors: Jin Li <lijin.abc@gmail.com>
	"""
	absdir=Path(__file__).parent
	scriptname=Path(__file__).stem
	script=[
		f"{absdir}/R/{scriptname}.R",
		]
	exprs=[
		f"outdir='{outdir}'",
		f"bname='{bname}'",
		f"skipcol={skipcol}",
		f"percent={percent}",
		f"infile='{infile}'",
		]
	Path(outdir).mkdir(parents=True, exist_ok=True)
	# os.chdir(outdir)
	return exeR.callback(exprs, script=script, condaenv=condaenv, verbose=True)

if __name__ == "__main__":
	sys.exit(main())
