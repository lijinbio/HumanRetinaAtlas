#!/usr/bin/env bash
# vim: set noexpandtab tabstop=2:

source trapdebug
indir=$(mrrdir.sh ../../scrnah5adaddmetadatamerge)
outdir=$(mrrdir.sh)

function cmd {
local f=$1
local group=$2
local bname=$(basename "$f" .h5ad)_$group

if fileexists.sh "$f"
then
	slurmtaco.sh -n g01 -t 2 -m 4G -- saturnh5adexpr2hclust -d "$outdir" -b "$bname" -e h5ad08 -g "$group" -c species -- "$f"
fi
}

source env_parallel.bash
env_parallel cmd ::: "$indir"/*.h5ad ::: labels group3 group4 group5
