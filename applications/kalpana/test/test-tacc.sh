#!/bin/bash

# Use Kalpana container on file within this directory

# Documentation
show_usage() {
	echo "Usage: $0 [FILE]"
	echo
	echo "A script to test a local Kalpana image ashtonvcole/kalpana-tacc:1.0.0"
	echo
	echo "Arguments:"
	echo "  FILE      An ADCIRC output file in the current directory"
	echo
	echo "Kalpana help:"
	docker run --rm \
		ashtonvcole/kalpana-tacc:1.0.0 \
		--help
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

mkdir "$1-tacc"

docker run --rm `# Remove after running` \
	-v "$(pwd):/mnt/host" `# Map current directory into container` \
	ashtonvcole/kalpana-tacc:1.0.0 `# Image` \
		`# python /Kalpana/Kalpana_N.py` \
		--storm test `# Storm name` \
		--filename "/mnt/host/$1" `# File name` \
		--filetype "$1" `# File` \
		--polytype polygon `# Polygon type` \
		--viztype shapefile `# As opposed to KMZ (Google Earth)` \
		--subplots no `# ???` \
		--output "/mnt/host/$1-tacc/" `# Output directory`
# --contourlevels '0 1 2 3 4 5 6 7 8 9 10 11 12' `# Contour levels` \
