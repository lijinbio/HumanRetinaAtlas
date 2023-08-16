#!/usr/bin/env bash
# vim: set noexpandtab tabstop=2:

source trapdebug
indir=$(mrrdir.sh ..)
outdir=$(mrrdir.sh)
# slurmtaco.sh -t 3 -m 60G -- scrnah5ad2postprocmetricswkfl -d "$outdir" -n -- "$indir"/*.h5ad
slurmtaco.sh -n d03 -t 4 -m 60G -- scrnah5ad2postprocmetricswkfl -t 8 -d "$outdir" -c config.yaml -- "$indir"/*.h5ad
