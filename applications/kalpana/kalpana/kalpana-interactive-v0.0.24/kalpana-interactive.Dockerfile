# My kalpana base
FROM ashtonvcole/kalpana:v0.0.24

# Using micromamba to install some libraries due to dependency problems
RUN micromamba install -c conda-forge -y \
		jupyterlab \
	&& micromamba clean --all -f -y

# Startup command: run Jupyter Lab
ENTRYPOINT ["/usr/local/bin/_entrypoint.sh", "jupyter", "lab"]

# Default arguments: setup containerized Jupyter
CMD ["--ip", "0.0.0.0", "--no-browser"]