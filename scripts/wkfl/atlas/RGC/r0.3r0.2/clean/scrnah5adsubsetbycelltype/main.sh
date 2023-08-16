#!/usr/bin/env bash
# vim: set noexpandtab tabstop=2:

source trapdebug
f=/storage/singlecell/jinli/wkfl/atlashumanprj/integration/snRNA/atlas/RGC/gpu_woD005/r0.3r0.2/scrnah5adbarcode2metadata/chen82_hackney.h5ad
outdir=$(mrrdir.sh)

clusters=(
2.2
3.1
3.7
10.0
)

function cmd {
local f=$1
local bname=$(basename "$f" .h5ad)
slurmtaco.sh -t 2 -m 10G -- scrnah5adsubsetbycelltype.sh -n -l leiden_1 $(basharr2cmdopts.sh -o -v -- "${clusters[@]}") -d "$outdir" -b "$bname" -- "$f"
}

source env_parallel.bash
env_parallel cmd ::: "$f"
