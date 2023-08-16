#!/usr/bin/env bash
# vim: set noexpandtab tabstop=2:

source trapdebug
outdir=$(mrrdir.sh)
slurmtaco.sh -n g01 -t 4 -m 60G -- saturnmultipleseedtrainbywkfl -d "$outdir" -e u_saturn -t 8 -c config.yaml -- BC_mouse_macaque.txt
