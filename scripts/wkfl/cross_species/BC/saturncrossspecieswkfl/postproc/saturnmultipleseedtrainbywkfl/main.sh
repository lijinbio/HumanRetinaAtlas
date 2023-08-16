#!/usr/bin/env bash
# vim: set noexpandtab tabstop=2:

source trapdebug
outdir=$(mrrdir.sh)
# slurmtaco.sh -n g01 -t 4 -m 60G -- saturnmultipleseedtrainbywkfl -d "$outdir" -e saturn -t 4 -n -- BC_mouse_macaque.txt
slurmtaco.sh -n g00 -t 4 -m 60G -- saturnmultipleseedtrainbywkfl -d "$outdir" -e saturn -t 20 -c config.yaml -- BC_mouse_macaque.txt
