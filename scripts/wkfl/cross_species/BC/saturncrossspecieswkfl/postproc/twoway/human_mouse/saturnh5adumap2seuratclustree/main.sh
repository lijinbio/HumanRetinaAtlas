#!/usr/bin/env bash
# vim: set noexpandtab tabstop=2:

source trapdebug
indir=$(mrrdir.sh ../scrnah5adaddmetadatamerge)
outdir=$(mrrdir.sh)

function cmd {
local f=$1
local group=$2
local bname=$(basename "$f" .h5ad)_$group

if fileexists.sh "$f"
then
	slurmtaco.sh -b -n d03 -t 2 -m 20G -- saturnh5adumap2seuratclustree -d "$outdir" -b "$bname" -e saturn -g "$group" -c species -H 5 -W 4 -- "$f" &
fi
}

source env_parallel.bash
env_parallel cmd ::: "$indir"/*.h5ad ::: labels group3 group4 group5
