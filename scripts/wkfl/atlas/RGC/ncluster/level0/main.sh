#!/usr/bin/env bash
# vim: set noexpandtab tabstop=2:

source trapdebug
indir=$(mrrdir.sh ../../scrnah5adfiles2scviwkfl)
outdir=$(mrrdir.sh)
# slurmtaco.sh -t 4 -m 40G -- scrnah5adscvi2leidenbyreswkfl -d "$outdir" -e u_scvi -t 4 -n -- "$indir"/*.h5ad
slurmtaco.sh -t 40 -m 80G -- scrnah5adscvi2leidenbyreswkfl -d "$outdir" -e u_scvi -t 40 -c config.yaml -- "$indir"/*.h5ad
