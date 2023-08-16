#!/usr/bin/env bash
# vim: set noexpandtab tabstop=2:

source trapdebug
indir=/storage/singlecell/jinli/wkfl/atlashumanprj/integration/snRNA/atlas/RGC/woD005/scrnah5adsubsetbycelltype
outdir=$(mrrdir.sh)
# slurmtaco.sh -n g01 -t 2 -m 20G -- scrnah5adfiles2scviwkfl -d "$outdir" -e u_scvi -n -- "$indir"/*.h5ad
slurmtaco.sh -n g01 -t 2 -m 20G -- scrnah5adfiles2scviwkfl -d "$outdir" -e u_scvi -c config.yaml -- "$indir"/*.h5ad
