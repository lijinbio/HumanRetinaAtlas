#!/usr/bin/env bash
# vim: set noexpandtab tabstop=2:

source trapdebug
indir=$(mrrdir.sh ../scrnah5addelfromobs)
outdir=$(mrrdir.sh)

function cmd {
local f=$1
local bname=$(basename "$f" .h5ad)

if fileexists.sh "$f"
then
	slurmtaco.sh -n d03 -t 2 -m 20G -- scrnah5adrenameobs.sh -d "$outdir" -b "$bname" -s leiden_1 -t cluster1 -s scpred_prediction -t majorclass -- "$f"
fi
}

source env_parallel.bash
env_parallel cmd ::: "$indir"/*.h5ad
