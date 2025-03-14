#!/bin/bash

echo "Local test: job ${_tapisJobUUID} execution at: $(date)"

# define jupyter config file
JUPYTER_CONFIG="/tmp/jupyter_config.py"

cat <<- EOF > ${JUPYTER_CONFIG}
# Configuration file for jupyter session
c = get_config()
c.IPKernelApp.pylab = "inline"  # if you want plotting support always
c.ServerApp.ip = "0.0.0.0"
c.ServerApp.port = ${LOGIN_PORT}
c.ServerApp.open_browser = False
c.ServerApp.allow_origin = u"*"
c.ServerApp.root_dir = "${HOME}"
c.ServerApp.preferred_dir = "${HOME}"
c.ServerApp.token = ""
c.ServerApp.terminado_settings = {'shell_command': ['/bin/bash', '--login', '-i']}
EOF

# Install kalpana kernel
bash -c 'source /opt/conda/etc/profile.d/conda.sh && conda activate kalpana && ipython kernel install --name=kalpana --user'

# launch jupyter
JUPYTER_ARGS="--config=${JUPYTER_CONFIG}"
echo "Local test: using jupyter command: jupyter-lab ${JUPYTER_ARGS}"

jupyter-lab ${JUPYTER_ARGS}
