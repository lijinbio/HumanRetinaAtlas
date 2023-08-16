#!/usr/bin/env bash
# vim: set noexpandtab tabstop=2:

source trapdebug
f=/storage/singlecell/jinli/wkfl/atlashumanprj/integration/snRNA/cross_species/saturncrossspecieswkfl/BC/s2k/n5k/saturntrainh5ad2umap/BC_mouse_macaque/BC_mouse_macaque.h5ad
outdir=$(mrrdir.sh)
bname=$(basename "$f" .h5ad)
slurmtaco.sh -t 2 -m 20G -- saturnh5adumap2seuratdimplotsplitby -d "$outdir" -b "$bname" -e saturn -g labels -s species -W 6 -W 6 -L 1 -- "$f"
