#!/usr/bin/env bash
# vim: set noexpandtab tabstop=2:

source trapdebug
indir=yaml
outdir=$(mrrdir.sh)
# slurmtaco.sh -t 8 -m 16G -n g00 -- saturnlatent2cntclassifierwkfl -d "$outdir" -e saturn -t 40 -n -- "$indir"/*.yaml
slurmtaco.sh -b -n d03 -t 20 -m 60G -- saturnlatent2cntclassifierwkfl -d "$outdir" -e saturn -t 16 -c config.yaml -- "$indir"/*.yaml &
