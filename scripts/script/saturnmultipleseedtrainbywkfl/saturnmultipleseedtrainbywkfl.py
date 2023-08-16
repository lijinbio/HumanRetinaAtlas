#!/usr/bin/env python3
# vim: set noexpandtab tabstop=2 shiftwidth=2 softtabstop=-1 fileencoding=utf-8:

import os
import sys
import shutil
from exeBash.exeBash import exeBash
from pathlib import Path
import datetime
import click

CONTEXT_SETTINGS=dict(help_option_names=['-h', '--help'])
@click.command(context_settings=CONTEXT_SETTINGS)
@click.option('-d', '--outdir', type=click.Path(resolve_path=True), default='.', show_default=True, help='Outdir.')
@click.option('-e', '--condaenv', type=click.STRING, help='Conda environment.')
@click.option('-c', '--configfile', type=click.Path(exists=False, resolve_path=True), help='Configuration file in the YAML format.')
@click.option('-t', '--numthreads', type=click.INT, default=1, show_default=True, help='Number of threads.')
@click.option('-b', '--bname', multiple=True, type=click.STRING, help='Bnames for infile. Default: basenames of infiles.')
@click.option('-n', '--dryrun', is_flag=True, help='Dry-run.')
@click.argument('infile', type=click.Path(exists=True, resolve_path=True), required=True, nargs=-1)
def main(outdir, condaenv, configfile, numthreads, bname, dryrun, infile):
	"""
To perform multiple seed comparison of cross-species analysis by SATURN.

INFILE is a sample TXT file. See `saturntraincrossspecies -h`.

\b
Example:
  slurmtaco.sh -n g01 -t 4 -m 60G -- saturnmultipleseedtrainbywkfl -d "$outdir" -e saturn -t 4 -n -- "$indir"/*.txt
  # slurmtaco.sh -n g01 -t 4 -m 60G -- saturnmultipleseedtrainbywkfl -d "$outdir" -e saturn -t 4 -c config.yaml -- "$indir"/*.txt

\b
Note:
  1. Exclusive access to a GPU device is achieved by multiprocess.Pool.starmap with cycling GPUs.
  1.1 multiprocess.Pool.starmap will run processes in blocks
  1.2 Fast processes will wait for the slowest one in the block
  GPU devices can be repeated in the list. E.g.,

\b
  ```
  saturntraincrossspecies:
    label: saturn_label
    batchkey: batch_label
    condaenv: saturn
    ngene: 5000
    nhvg: 8000
    hvgspan: 1.0
    mapfile: null
    epoch: 50
    gpu:
    - 0
    - 0
    - 1
    - 1
    - 2
    - 2
    nseed: 20
  ```

\b
See also:
  Steps:
    saturntraincrossspecies
    saturntrainh5ad2umap
    saturnh5adumap2seuratdimplotsplitby
    saturnh5adumap2seuratclustree
  Upstream:
    saturncrossspecieswkfl
    saturntraincrossspecies

\b
Date: 2023/03/17
Authors: Jin Li <lijin.abc@gmail.com>
	"""
	if len(bname)!=len(infile):
		bname=[Path(file).stem for file in infile]
	Path(outdir).mkdir(parents=True, exist_ok=True)
	absdir=Path(__file__).parent
	nowtimestr=datetime.datetime.now().strftime('%y%m%d_%H%M%S')

	for file in [
			f"{absdir}/snakemake/Snakefile",
			f"{absdir}/snakemake/config.smk",
			]:
		shutil.copy2(file, outdir) # copy Snakfile and config.smk

	# common command string
	cmdstr=[
		f"snakemake",
		f"-C outdir='{outdir}' infile='{','.join(infile)}' bname='{','.join(bname)}' condaenv='{condaenv}' nowtimestr='{nowtimestr}'",
		f"-d {outdir}",
		f"-j {numthreads}",
		]
	if configfile:
		cmdstr+=[f"--configfile {configfile}"]

	if dryrun: # dry-run
		cmdstr+=[f"-n -p"]

	else: # running
		cmdstr+=[
			f"-r -p --debug-dag",
			f"--stats Snakefile_{nowtimestr}.stats",
			]

	os.chdir(outdir)
	return exeBash.callback(cmdstr=cmdstr, condaenv=None, verbose=True)

if __name__ == "__main__":
	sys.exit(main())
