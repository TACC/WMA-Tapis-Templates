set -x

apptainer run \
    --cleanenv \
    --bind "${inputDirectory}":/data \
    docker://taccaci/opensees:3.7.0 \
    /bin/sh -c \
        "cd /data; OpenSees < /data/$tclScript"

EXITCODE=$?
if [ $EXITCODE -ne 0 ]; then
    # Command failed
    echo "Apptainer container exited with an error status. $EXITCODE" >&2

    # https://tapis.readthedocs.io/en/latest/technical/jobs.html#monitoring-the-application
    echo $EXITCODE > ${_tapisExecSystemOutputDir}/tapisjob.exitcode
fi
