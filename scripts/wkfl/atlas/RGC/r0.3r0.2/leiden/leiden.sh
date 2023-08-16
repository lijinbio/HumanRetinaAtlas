#!/usr/bin/env bash
# vim: set noexpandtab tabstop=2:

source trapdebug
f=$(mrrdir.sh)/chen82_hackney_0.3_0.2_obs.txt.gz
outdir=$(mrrdir.sh)
zcat "$f" | hcut.sh barcode leiden_0 leiden_1 | tofile.sh -o "$outdir/leiden.txt.gz"
