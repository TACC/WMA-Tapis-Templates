# My kalpana base
FROM ashtonvcole/kalpana:v0.0.24

# Copy run script into container
COPY main.py /home/mambauser

# Startup command: run Jupyter Lab
ENTRYPOINT ["/usr/local/bin/_entrypoint.sh", "python", "main.py"]

# Default argument: show help
CMD ["--help"]