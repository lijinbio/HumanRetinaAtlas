#!/usr/bin/env bash
# vim: set noexpandtab tabstop=2:

source trapdebug
indir=$(mrrdir.sh ../scrnah5adfiles2scviwkfl)
outdir=$(mrrdir.sh)
define=(
scrnah5adscvi2sccaf.condaenv:=:sccaf
)
# slurmtaco.sh -t 3 -m 60G -- scrnah5ad2postprocmetricswkfl -d "$outdir" -n -- "$indir"/*.h5ad
slurmtaco.sh -n d03 -t 4 -m 60G -- scrnah5ad2postprocmetricswkfl -t 8 -e u_scvi -d "$outdir" -c config.yaml $(basharr2cmdopts.sh -o -D -- "${define[@]}") -- "$indir"/*.h5ad
