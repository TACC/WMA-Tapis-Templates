#!/bin/bash

# Show usage if help is requested
show_usage() {
    echo "Usage: $0 INPUT_DIR [KALPANA_ARGS...]"
    echo
    echo "Arguments:"
    echo "  INPUT_DIR      Directory containing ADCIRC output files"
    echo "  KALPANA_ARGS   Additional arguments passed directly to Kalpana"
    echo
    echo "Example:"
    echo "  $0 /path/to/adcirc/files -f maxele.63.nc -o flood_contours"
    echo "  $0 ./my_data -f maxwvel.63.nc -t polyline -o wind_contours -l '0,10,20,30,40,50'"
    exit 1
}

# Show help if requested
if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
    show_usage
fi

# Check if input directory is provided
if [ $# -eq 0 ]; then
    echo "Error: Input directory not specified"
    show_usage
fi

# Get the input directory from first argument
INPUT_DIR=$(realpath "$1")
shift  # Remove the first argument, leaving any remaining args for Kalpana

# Check if directory exists
if [ ! -d "$INPUT_DIR" ]; then
    echo "Error: Directory not found: $INPUT_DIR"
    exit 1
fi

# Run the container with input directory mounted
docker run --rm \
    -v "$INPUT_DIR":/data \
    clos21/kalpana:test "$@"