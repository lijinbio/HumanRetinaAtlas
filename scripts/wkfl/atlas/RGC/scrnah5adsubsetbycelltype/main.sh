#!/usr/bin/env bash
# vim: set noexpandtab tabstop=2:

source trapdebug
f=/storage/singlecell/jinli/wkfl/atlashumanprj/integration/snRNA/atlas/RGC/scrnah5adsubsetbycelltype/chen82_hackney.h5ad
outdir=$(mrrdir.sh)

function cmd {
local f=$1
local bname=$(basename "$f" .h5ad)
slurmtaco.sh -t 2 -m 40G -n g01 -- scrnah5adsubsetbycelltype.sh -n -l sampleid -v Chen_rgc_10x3v31_19_D005_Macular_NeuN_T -d "$outdir" -b "$bname" -- "$f"
}

source env_parallel.bash
env_parallel cmd ::: "$f"
