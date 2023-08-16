#!/usr/bin/env bash
# vim: set noexpandtab tabstop=2:

source trapdebug
indir=../yaml
outdir=$(mrrdir.sh)
# slurmtaco.sh -t 8 -m 16G -- saturnlatent2cntclassifierwkfl -d "$outdir" -e saturn -t 40 -n -- "$indir"/*.yaml
slurmtaco.sh -n d03 -t 8 -m 60G -- saturnlatent2cntclassifierwkfl -d "$outdir" -e saturn -t 40 -c config.yaml -- "$indir"/*.yaml
