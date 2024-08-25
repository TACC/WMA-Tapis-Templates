FROM nvidia/cuda:12.3.0-devel-ubuntu22.04

LABEL maintainer="TACC-ACI-WMA <wma_prtl@tacc.utexas.edu>"

USER root

EXPOSE 8888

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    fonts-liberation \
    git \
    locales \
    pandoc \
    python3 \
    python3-pip \
    ssh \
    vim \
    && apt-get clean && rm -rf /var/lib/apt/lists/* && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen

RUN pip install --upgrade --no-cache-dir \
    pip \
    setuptools \
    wheel

# Install jupyterlab and ML packages using host cache
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install \
    jupyterlab \
    tensorflow[and-cuda] \
    torch

# Add container user and group
ARG NB_USER=jovyan
ARG NB_UID=1000
ARG NB_GID=100

# Configure environment
ENV SHELL=/bin/bash \
    NB_USER="${NB_USER}" \
    NB_UID=${NB_UID} \
    NB_GID=${NB_GID} \
    NB_HOME="/home/${NB_USER}" \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8

# Enable prompt color in the skeleton .bashrc before creating the default NB_USER
RUN sed -i 's/^#force_color_prompt=yes/force_color_prompt=yes/' /etc/skel/.bashrc

# Create NB_USER with UID=NB_UID and GID=NB_GID
RUN useradd --no-log-init --create-home --shell /bin/bash --uid "${NB_UID}" --gid "${NB_GID}" "${NB_USER}"

COPY run.sh /tapis/run.sh

RUN chmod +x /tapis/run.sh

USER ${NB_UID}

# Setup work directory
RUN mkdir "${NB_HOME}/work"

WORKDIR "${NB_HOME}"

ENTRYPOINT [ "/tapis/run.sh" ]
