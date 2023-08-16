#!/usr/bin/env bash
# vim: set noexpandtab tabstop=2:

source trapdebug
indir=$(mrrdir.sh ../../scrnah5adfiles2scviwkfl)
metadata=$(mrrdir.sh ../leiden)/leiden.txt.gz
outdir=$(mrrdir.sh)

function cmd {
local f=$1
local bname=$(basename "$f" .h5ad)

if fileexists.sh "$f"
then
	slurmtaco.sh -t 2 -m 30G -n d03 -- scrnah5adbarcode2metadata.sh -d "$outdir" -b "$bname" -m "$metadata" -C -- "$f"
fi
}

source env_parallel.bash
env_parallel cmd ::: "$indir"/*.h5ad
