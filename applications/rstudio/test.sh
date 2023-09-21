#!/bin/bash

module load tacc-apptainer

NODE_HOSTNAME_PREFIX=$(hostname -s)   # Short Host Name  -->  name of compute node: c###-###
NODE_HOSTNAME_DOMAIN=$(hostname -d)   # DNS Name  -->  frontera.tacc.utexas.edu

echo "TACC: running on node $NODE_HOSTNAME_PREFIX on $NODE_HOSTNAME_DOMAIN"

TAP_FUNCTIONS="/share/doc/slurm/tap_functions"
if [ -f ${TAP_FUNCTIONS} ]; then
    . ${TAP_FUNCTIONS}
else
    echo "TACC:"
    echo "TACC: ERROR - could not find TAP functions file: ${TAP_FUNCTIONS}"
    echo "TACC: ERROR - Please submit a consulting ticket at the TACC user portal"
    echo "TACC: ERROR - https://portal.tacc.utexas.edu/tacc-consulting/-/consult/tickets/create"
    echo "TACC:"
    echo "TACC: job $SLURM_JOB_ID execution finished at: $(date)"
    exit 1
fi

LOGIN_PORT=$(tap_get_port)
echo "TACC: got login port ${LOGIN_PORT}"

SESSION_URL="https://${NODE_HOSTNAME_DOMAIN}:${LOGIN_PORT}"
echo "SESSION_URL is $SESSION_URL"

mkdir -p ${HOME}/.tap # this should exist at this point, but just in case...
TAP_CERTFILE=${HOME}/.tap/.${SLURM_JOB_ID}

LOCAL_PORT=8080

for i in `seq 4`; do
  ssh -o StrictHostKeyChecking=no -f -g -N -R ${LOGIN_PORT}:${NODE_HOSTNAME_PREFIX}:${LOCAL_PORT} login${i}
done

workdir=$(python -c 'import tempfile; print(tempfile.mkdtemp())')

mkdir -p -m 700 ${workdir}/run ${workdir}/tmp ${workdir}/var/lib/rstudio-server
cat > ${workdir}/database.conf <<END
provider=sqlite
directory=/var/lib/rstudio-server
END

# Set OMP_NUM_THREADS to prevent OpenBLAS (and any other OpenMP-enhanced
# libraries used by R) from spawning more threads than the number of processors
# allocated to the job.
#
# Set R_LIBS_USER to a path specific to rocker/rstudio to avoid conflicts with
# personal libraries from any R installation in the host environment

cat > ${workdir}/rsession.sh <<END
#!/bin/sh
export OMP_NUM_THREADS=${SLURM_JOB_CPUS_PER_NODE}
export R_LIBS_USER=${HOME}/R/rocker-rstudio/4.3
exec /usr/lib/rstudio-server/bin/rsession "\${@}"
END

chmod +x ${workdir}/rsession.sh

# export APPTAINER_BIND="${workdir}/run:/run,${workdir}/tmp:/tmp,${workdir}/database.conf:/etc/rstudio/database.conf,${workdir}/rsession.sh:/etc/rstudio/rsession.sh,${workdir}/var/lib/rstudio-server:/var/lib/rstudio-server"

# Do not suspend idle sessions.
# Alternative to setting session-timeout-minutes=0 in /etc/rstudio/rsession.conf
# https://github.com/rstudio/rstudio/blob/v1.4.1106/src/cpp/server/ServerSessionManager.cpp#L126
export APPTAINERENV_RSTUDIO_SESSION_TIMEOUT=0
export APPTAINERENV_USER=$(id -un)
export APPTAINERENV_PASSWORD=$(openssl rand -base64 15)
echo "username is $APPTAINERENV_USER with password $APPTAINERENV_PASSWORD"

apptainer shell \
    --cleanenv \
    --contain \
    --fakeroot \
    --writable-tmpfs \
    --bind ${workdir}/run:/run \
    --bind ${workdir}/tmp:/tmp \
    --bind ${workdir}/database.conf:/etc/rstudio/database.conf \
    --bind ${workdir}/rsession.sh:/etc/rstudio/rsession.sh \
    --bind ${workdir}/var/lib/rstudio-server:/var/lib/rstudio-server \
    --bind $(cat ${TAP_CERTFILE}):/etc/nginx/ssl/session.crt \
    docker://taccaci/rstudio:4.3 \
        /usr/lib/rstudio-server/bin/rserver \
            --www-port 8787 \
            --www-address 0.0.0.0 \
            --auth-none=0 \
            --auth-pam-helper-path=pam-helper \
            --server-user=$(whoami) \
            --auth-stay-signed-in-days=30 \
            --auth-timeout-minutes=0 \
            --rsession-path=/etc/rstudio/rsession.sh

echo "TACC: release port returned $(tap_release_port ${LOGIN_PORT} 2> /dev/null)"
