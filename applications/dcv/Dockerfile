FROM ubuntu:jammy as dcv

USER root

ARG DEBIAN_FRONTEND=noninteractive

# Prepare the container to run systemd inside
ENV container docker

# Install tools
RUN apt-get update && apt-get install -y \
    tar \
    vim \
    wget \
    kmod \
    software-properties-common \
    apt-transport-https \
    sudo \
    pciutils \
    ca-certificates \
    xz-utils \
    locales \
    curl \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

# install X Server, Gnome and GL libs/dependencies
RUN apt-get update && apt-get install -y \
    mesa-utils \
    libxvmc-dev \
    libxatracker-dev \
    xserver-xorg-core \
    xserver-xorg \
    xserver-xorg-dev \
    xserver-xorg-video-dummy \
    xorg \
    x11-utils \
    xauth \
    xinit  \
    openbox \
    xfonts-base \
    xterm \
    freeglut3 \
    ubuntu-desktop-minimal \
    gnome-shell \
    gdm3 \
    libglfw3-dev \
    libgles2-mesa-dev \
    libglew-dev \
    glew-utils \
    && rm -rf /var/lib/apt/lists/*

# # Install Nvidia Driver, configure Xorg, install NICE DCV server
# ENV NVIDIA_VISIBLE_DEVICES all
# # ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
# ENV NVIDIA_DRIVER_CAPABILITIES all
# ADD NVIDIA-installer.run /tmp/NVIDIA-installer.run
# RUN wget -q http://us.download.nvidia.com/XFree86/Linux-x86_64/430.26/NVIDIA-Linux-x86_64-430.26.run -O /tmp/NVIDIA-installer.run
# RUN  bash /tmp/NVIDIA-installer.run --accept-license \
#     --install-libglvnd \
#     --no-questions --no-kernel-module-source \
#     --no-nvidia-modprobe --no-kernel-module \
#     --disable-nouveau \
#     --no-backup \
#     --ui=none \
#     && rm -f /tmp/NVIDIA-installer.run \
#     && nvidia-xconfig --preserve-busid --enable-all-gpus -connected-monitor=DFP-0,DFP-1,DFP-2,DFP-3

# Install NICE DCV
RUN mkdir -p /tmp/dcv-inst \
    && cd /tmp/dcv-inst \
    && wget https://d1uj6qtbmh3dt5.cloudfront.net/NICE-GPG-KEY \
    && gpg --import NICE-GPG-KEY \
    && wget https://d1uj6qtbmh3dt5.cloudfront.net/nice-dcv-ubuntu2204-x86_64.tgz \
    && tar -xvzf nice-dcv-ubuntu2204-x86_64.tgz && cd nice-dcv-2023.0-15487-ubuntu2204-x86_64 \
    && apt-get update && apt-get install -y \
    ./nice-dcv-server_2023.0.15487-1_amd64.ubuntu2204.deb \
    ./nice-dcv-web-viewer_2023.0.15487-1_amd64.ubuntu2204.deb \
    ./nice-xdcv_2023.0.551-1_amd64.ubuntu2204.deb \
    # ./nice-dcv-gl_2023.0.1039-1_amd64.ubuntu2204.deb \
    && usermod -aG video dcv \
    && rm -rf /tmp/dcv-inst

# Define the dcvserver.service
COPY dcvserver.service /usr/lib/systemd/system/dcvserver.service

# Copy the NICE DCV license file
COPY license.lic /etc/dcv/license.lic

# Send Notification message DCV session ready
# COPY send_dcvsessionready_notification.sh /usr/local/bin/

# Open required port on firewall, create test user, send notification, start DCV session for the user
# COPY startup_script.sh /usr/local/bin

# Start DCV server and initialize level 5
# COPY run_script.sh /usr/local/bin/

# Append the startup script to be executed at the end of initialization and fix permissions
# RUN chmod +x "/usr/local/bin/run_script.sh" \
#     "/usr/local/bin/send_dcvsessionready_notification.sh" \
#     "/usr/local/bin/startup_script.sh"

EXPOSE 8443

# CMD ["/usr/local/bin/run_script.sh"]

COPY run.sh /tapis/run.sh

RUN chmod +x /tapis/run.sh

ENTRYPOINT ["/tapis/run.sh"]
