#!/usr/bin/env bash
# vim: set noexpandtab tabstop=2:

source trapdebug
indir=$(mrrdir.sh ../scrnah5adaddmetadatamerge)
outdir=$(mrrdir.sh)

function cmd {
local f=$1
local bname=$(basename "$f" .h5ad)
slurmtaco.sh -b -n d03 -t 2 -m 20G -- saturnh5adumap2seuratdimplotsplitby -d "$outdir" -b "$bname" -e saturn -g labels -g group3 -g group4 -g group5 -s species -W 6 -W 6 -L 1 -- "$f" &
}

source env_parallel.bash
env_parallel cmd ::: "$indir"/*.h5ad
