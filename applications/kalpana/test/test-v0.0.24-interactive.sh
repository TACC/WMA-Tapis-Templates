#!/bin/bash

docker run --rm -it \
	-p 8888:8888 \
	-v "$(pwd):/home/mambauser/host" \
	ashtonvcole/kalpana:v0.0.24-jupyter-lab