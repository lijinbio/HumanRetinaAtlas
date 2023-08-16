#!/usr/bin/env bash
# vim: set noexpandtab tabstop=2:

source trapdebug
f=/storage/singlecell/jinli/wkfl/atlashumanprj/integration/snRNA/atlas/RGC/gpu_woD005/ncluster/level1/chen82_hackney_0.3_0.2_obs.txt.gz
outdir=$(mrrdir.sh)
rsync.sh -d "$outdir" -- "$f"
