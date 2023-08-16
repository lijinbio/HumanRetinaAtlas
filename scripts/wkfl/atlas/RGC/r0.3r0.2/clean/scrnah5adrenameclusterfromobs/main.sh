#!/usr/bin/env bash
# vim: set noexpandtab tabstop=2:

source trapdebug
indir=$(mrrdir.sh ../scrnah5adrenameobs)
outdir=$(mrrdir.sh)

function cmd {
local f=$1
local bname=$(basename "$f" .h5ad)

if fileexists.sh "$f"
then
	slurmtaco.sh -n d03 -t 1 -m 20G -- scrnah5adrenameclusterfromobs -d "$outdir" -b "$bname" -p H -g majorclass -m cluster1 -n cluster2 -- "$f"
fi
}

source env_parallel.bash
env_parallel cmd ::: "$indir"/*.h5ad
