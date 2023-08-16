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
@click.option('-e', '--condaenv', type=click.STRING, help='Conda environment, e.g., scvi_gpu.')
@click.option('-c', '--configfile', type=click.Path(exists=False, resolve_path=True), help='Configuration file in the YAML format.')
@click.option('-t', '--numthreads', type=click.INT, default=4, show_default=True, help='Number of threads.')
@click.option('-y', '--yaml', is_flag=True, help='Do not run, but save default configurations (bname.yaml) only.')
@click.option('-b', '--bname', multiple=True, type=click.STRING, help='Bnames for infile. Default: basenames of infiles.')
@click.option('-n', '--dryrun', is_flag=True, help='Dry-run.')
@click.argument('infile', type=click.Path(exists=True, resolve_path=True), required=True, nargs=-1)
def main(outdir, condaenv, configfile, numthreads, yaml, bname, dryrun, infile):
	"""
To run leiden clustering of various resolutions from .h5ad files. `x.obsm['X_scVI']` and `x.obsm['X_umap']` are assumed.

INFILE are .h5ad file[s].

\b
Example:
  indir=/storage/singlecell/jinli/.local/jlpywrapper/jlscRNAwkfl/src/scrnah5adfiles2scviwkfl/main
  outdir=$(mrrdir.sh)
  slurmtaco.sh -t 4 -m 40G -- scrnah5adscvi2leidenbyreswkfl -n -d "$outdir" -e scvi_gpu -- "$indir"/*.h5ad
  ## cp -i $(mrrdir.sh)/config.yaml .
  slurmtaco.sh -t 4 -m 40G -- scrnah5adscvi2leidenbyreswkfl -n -d "$outdir" -e scvi_gpu -c config.yaml -- "$indir"/*.h5ad

\b
Note:
  1. One example configuration file.

\b
  ```
  absdir: /storage/chen/home/u236923/.local/jlpywrapper/jlscRNAwkfl/src/scrnah5adscvi2leidenbyreswkfl/main/resolution2/../..
  outdir: /storage/singlecell/jinli/.local/jlpywrapper/jlscRNAwkfl/src/scrnah5adscvi2leidenbyreswkfl/main/resolution2
  infile:
  - /storage/singlecell/jinli/.local/jlpywrapper/jlscRNAwkfl/src/scrnah5adfiles2scviwkfl/main/HC.h5ad
  - /storage/singlecell/jinli/.local/jlpywrapper/jlscRNAwkfl/src/scrnah5adfiles2scviwkfl/main/NN.h5ad
  bname:
  - HC
  - NN
  condaenv: scvi_gpu
  scrnah5adscvi2leidensbyresolution:
    condaenv: scvi_gpu
    label:
    - resolution_1
    - resolution_2
    resolution_1:
    - 0.2
    - 0.3
    resolution_2:
    - 0.2
    - 0.3
    seed: 12345
  ```

\b
  2. `-e|--condaenv` will set the conda environment for all internal steps, and it has a higher priority over the `config.yaml`.

\b
See also:
  Upstream:
    scrnah5adfiles2scviwkfl
    scrnah5adrawcounts2scviwkfl
  Steps:
    scrnah5adscvi2leidensbyresolution
    mergeimg2htmlbyjinja
    numcluster: number of clusters per resolution
  Depends:
    Python/Scanpy

\b
Date: 2023/01/24
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
		f"-C absdir='{absdir}' outdir='{outdir}' infile='{','.join(infile)}' bname='{','.join(bname)}' condaenv='{condaenv}' nowtimestr='{nowtimestr}'",
		f"-d {outdir}",
		f"-j {numthreads}",
		]
	if configfile:
		cmdstr+=[f"--configfile {configfile}"]

	if dryrun: # dry-run
		cmdstr+=[f"-n -p"]

	elif yaml: # Save config.yaml only
		cmdstr+=[f"-s config.smk"]

	else: # running
		cmdstr+=[
			f"-r -p --debug-dag",
			f"--stats Snakefile_{nowtimestr}.stats",
			]

	os.chdir(outdir)
	return exeBash.callback(cmdstr=cmdstr, condaenv=None, verbose=True)

if __name__ == "__main__":
	sys.exit(main())
