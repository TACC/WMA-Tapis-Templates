#!/bin/bash

# Run the Docker container
docker run -it --rm \
    -v $(pwd):/workspace \
    -e LOGIN_PORT=8888 \
    -p 8888:8888 \
    --entrypoint /tapis/test_run.sh \
    --name adcirc-interactive \
    clos21/ds-adcirc-interactive:test
