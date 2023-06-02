FROM taccaci/jupyter-lab-hpc

# The user must be swtiched to root in order to install and update packages with apt-get.
# See https://github.com/jupyter/docker-stacks/blob/master/base-notebook/Dockerfile for info.
USER root

RUN wget https://download.open-mpi.org/release/open-mpi/v5.0/openmpi-5.0.0rc12.tar.gz -P /tmp

RUN tar xf /tmp/openmpi-5.0.0rc12.tar.gz -C /tmp

WORKDIR /tmp/openmpi-5.0.0rc12

RUN ./configure 2>&1 | tee config.out

RUN make all 2>&1 | tee make.out

RUN make install 2>&1 | tee install.out

# The user is switched back to the one from set in the base image.
USER 1000

ENTRYPOINT [ "/tapis/run.sh" ]
