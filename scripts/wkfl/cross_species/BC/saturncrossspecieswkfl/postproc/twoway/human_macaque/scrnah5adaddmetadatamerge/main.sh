#!/usr/bin/env bash
# vim: set noexpandtab tabstop=2:

source trapdebug
f=/storage/singlecell/jinli/wkfl/atlashumanprj/integration/snRNA/cross_species/saturncrossspecieswkfl/BC/s2k/n5k/saturntrainh5ad2umap/BC_macaque/BC_macaque.h5ad
metadata=table.txt
outdir=$(mrrdir.sh)

function cmd {
local f=$1
local bname=$(basename "$f" .h5ad)

if fileexists.sh "$f"
then
	slurmtaco.sh -b -n g01 -t 2 -m 20G -- scrnah5adaddmetadatamerge.sh -e saturn -d "$outdir" -b "$bname" -m "$metadata" -k labels -- "$f" &
fi
}

source env_parallel.bash
env_parallel cmd ::: "$f"
