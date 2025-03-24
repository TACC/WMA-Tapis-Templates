Jupyter HPC Native runs a native jupyter instance on Vista. At the moment, this only runs on Vista with this profile.

The app script will load python3 module, and launch jupyter-lab if that exists, or jupyter-notebook if lab is not found.

JUPYTER_HOME is defined as, $HOME/.jupyter-hpc-native, meaning state will persist between sessions.
