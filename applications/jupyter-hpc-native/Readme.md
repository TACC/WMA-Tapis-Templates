### Overview
Jupyter HPC Native runs a native jupyter instance on a compute node. It loads the latest python3 module for the system it runs on, and executes jupyter-lab, or jupyter-notebook if jupyter-lab is unavailable.

### Runtime
For Vista, the app utilizes the TAP utilities and a baseline `tap-ilogin.sh` file to reverse proxy the compute node and jupyter port to a secure port. Script is imported from `tapis://cloud.data/corral/tacc/aci/CEP/applications/v3/interactive-template/tap/tap-ilogin.sh`.

For all other execution systems, the app utilizes the TAP utilities and a baseline `tap.sh` file to reverse proxy the compute node and jupyter port to a secure port. Script is imported from `tapis://cloud.data/corral/tacc/aci/CEP/applications/v3/interactive-template/tap/tap.sh`.

`$JUPYTER_HOME` is defined as `$HOME/.jupyter-hpc-native`, meaning state will persist between sessions.

`$WORK`, `$HOME`, `$SCRATCH`, and `DesignSafe MyData` are symlinked into the base execution directory / home dir of the jupyter session, for easy access.

### Parameters
A user can specify a custom python kernel to use within the session.
