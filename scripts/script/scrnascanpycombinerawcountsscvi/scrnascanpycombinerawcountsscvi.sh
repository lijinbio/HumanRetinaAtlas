#!/usr/bin/env bash
# vim: set noexpandtab tabstop=2:

args=$(getopt -o hd:b:s:r:v: -l help,outdir:,bname:,obs:,rawcount:,scvi: --name "$0" -- "$@") || exit "$?"
eval set -- "$args"

absdir=$(dirname $(readlink -f "$0"))
scriptname=$(basename "$0" .sh)

outdir=.
while true
do
	case "$1" in
		-h|--help)
			exec cat "$absdir/$scriptname.txt"
			;;
		-d|--outdir)
			outdir=$2
			shift 2
			;;
		-b|--bname)
			bname=$2
			shift 2
			;;
		-s|--obs)
			obs+=("$2")
			shift 2
			;;
		-r|--rawcount)
			rawcount=$2
			shift 2
			;;
		-v|--scvi)
			scvi=$2
			shift 2
			;;
		--)
			shift
			break
			;;
		*)
			echo "$0: not implemented option: $1" >&2
			exit 1
			;;
	esac
done

[[ $bname ]] || { echo "$scriptname.sh: -b|--bname must be specified!"; exit 1; }
[[ $rawcount ]] || { echo "$scriptname.sh: -r|--rawcount must be specified!"; exit 1; }
[[ $scvi ]] || { echo "$scriptname.sh: -v|--scvi must be specified!"; exit 1; }

source traptimes
SECONDS=0
set -xe
hdf5ls.sh "$rawcount" "$scvi"
mkdir -p "$outdir" && pycmd.sh \
	-e "rawcount='$rawcount'" \
	-e "scvi='$scvi'" \
	-e "outdir='$outdir'" \
	-e "bname='$bname'" \
	-e "obss=$(basharr2pylist.sh -c -- "${obs[@]}")" \
	-s "$absdir/python/$scriptname.py"
set +x
echo "Time elapsed: $(date -u -d @$SECONDS +'%H:%M:%S')"
