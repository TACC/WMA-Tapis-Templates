#!/bin/bash

# Use Kalpana container on file within this directory

# Documentation
show_usage() {
	echo "Usage: $0 [FILE]"
	echo
	echo "A script to test a local Kalpana image ashtonvcole/kalpana:v0.0.24"
	echo
	echo "Arguments:"
	echo "  FILE      A Python script which calls Kalpana functions"
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
	-p 8888:8888 \
	-v "$(pwd):/mnt/host" \
	ashtonvcole/kalpana:v0.0.24 \
		/mnt/host/$1