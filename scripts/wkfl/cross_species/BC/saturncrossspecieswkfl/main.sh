#!/usr/bin/env bash
# vim: set noexpandtab tabstop=2:

source trapdebug
indir=yaml
outdir=$(mrrdir.sh)
# slurmtaco.sh -t 2 -m 50G -n g01 -- saturncrossspecieswkfl -d "$outdir" -e saturn -t 20 -n -- "$indir"/*.yaml
# slurmtaco.sh -t 2 -m 50G -n d02 -- saturncrossspecieswkfl -d "$outdir" -e saturn -t 20 -c config.yaml -- "$indir"/*.yaml
slurmtaco.sh -t 2 -m 50G -n g01 -- saturncrossspecieswkfl -d "$outdir" -e saturn -t 20 -c config.yaml -- "$indir"/*.yaml
