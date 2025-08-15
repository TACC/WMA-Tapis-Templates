#!/bin/bash

# Use Kalpana container on file within this directory

# Documentation
show_usage() {
	echo "Usage: $0 [FILE]"
	echo
	echo "A script to test a local Kalpana image ashtonvcole/kalpana:v0.0.24-"
	echo "nc2shp"
	echo
	echo "Arguments:"
	echo "  FILE       An ADCIRC output file in the current directory"
	echo
	echo "Kalpana help:"
	echo "https://github.com/ccht-ncsu/Kalpana"
}

# Show help if requested
if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
    show_usage
fi

# Check if input file is provided
if [ $# -eq 0 ]; then
    echo "Error: Input file not specified"
    show_usage
	exit 1
fi

docker run --rm -it \
	-v "$(pwd):/mnt/host" \
	ashtonvcole/kalpana:v0.0.24-nc2shp \
		--ncFile /mnt/host/$1 \
		--var zeta_max \
		--levels 0 5.5 0.5 \
		--conType polygon \
		--pathOut /mnt/host/contours.gpkg \
		--epsgOut 4326