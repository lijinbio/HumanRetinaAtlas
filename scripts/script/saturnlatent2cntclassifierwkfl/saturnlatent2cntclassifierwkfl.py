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
@click.option('-e', '--condaenv', type=click.STRING, help='Conda environment, e.g., sccaf.')
@click.option('-c', '--configfile', type=click.Path(exists=False, resolve_path=True), help='Configuration file in the YAML format.')
@click.option('-t', '--numthreads', type=click.INT, default=4, show_default=True, help='Number of threads.')
@click.option('-b', '--bname', multiple=True, type=click.STRING, help='Bnames for infile. Default: basenames of infiles.')
@click.option('-n', '--dryrun', is_flag=True, help='Dry-run.')
@click.argument('infile', type=click.Path(exists=True, resolve_path=True), required=True, nargs=-1)
def main(outdir, condaenv, configfile, numthreads, bname, dryrun, infile):
	"""
To perform classification analysis from SATURN co-embedding. This is re-analysis of classification steps from `saturncrossspecieswkfl`. Might be adapted to `saturncrossspecieswkfl`.

INFILE are configuration YAML file[s]. E.g.,

\b
```sample.yaml
- species: human
  path: /storage/singlecell/jinli/wkfl/atlashumanprj/integration/snRNA/cross_species/saturncrossspecieswkfl/BC/s2k/scrnah5adsplitby/BC_mouse_macaque/BC_mouse_macaque_human.h5ad
  classifier: predict
  metadata: /storage/singlecell/jinli/wkfl/atlashumanprj/integration/snRNA/cross_species/saturncrossspecieswkfl/BC/s2k/scrnah5adsubsetbyvaluecounts/BC_mouse_macaque/human_obs.txt.gz
- species: mouse
  path: /storage/singlecell/jinli/wkfl/atlashumanprj/integration/snRNA/cross_species/saturncrossspecieswkfl/BC/s2k/scrnah5adsplitby/BC_mouse_macaque/BC_mouse_macaque_mouse.h5ad
  classifier: train
- species: macaque
  path: /storage/singlecell/jinli/wkfl/atlashumanprj/integration/snRNA/cross_species/saturncrossspecieswkfl/BC/s2k/scrnah5adsplitby/BC_mouse_macaque/BC_mouse_macaque_macaque.h5ad
  classifier: train
```

\b
Example:
  slurmtaco.sh -n g01 -t 4 -m 60G -- saturnlatent2cntclassifierwkfl -d "$outdir" -e saturn -t 4 -n -- sample.yaml

\b
See also:
  Steps:
    saturnh5adlatent2cntclassifier
    # rtable2sankeydiagram
    tsvfileaddfromcolumn
    tsvfileaddfromcolumn/saturncntclassifierpred2tab
    tsvfileaddfromcolumn/rtable2sankeydiagram
  Related:
    saturncrossspecieswkfl

\b
Date: 2023/03/12
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
			f"{absdir}/snakemake/train.smk",
			f"{absdir}/snakemake/trainby.smk",
			f"{absdir}/snakemake/trainby_woscale.smk",
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
