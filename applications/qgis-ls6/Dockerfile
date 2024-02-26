FROM ubuntu:22.04

ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

RUN echo "tzdata tzdata/Areas select America" >> preseed.txt
RUN echo "tzdata tzdata/Zones/America select Chicago" >> preseed.txt
RUN debconf-set-selections preseed.txt

RUN apt -y update && apt -y upgrade

RUN apt install -y gnupg software-properties-common wget curl

RUN apt-get install -y bison build-essential ca-certificates ccache cmake \
    cmake-curses-gui dh-python doxygen expect flex flip gdal-bin git \
    graphviz grass-dev libdraco-dev libexiv2-dev libexpat1-dev libfcgi-dev \
    libgdal-dev libgeos-dev libgsl-dev libpdal-dev libpq-dev libproj-dev \
    libprotobuf-dev libqca-qt5-2-dev libqca-qt5-2-plugins libqscintilla2-qt5-dev \
    libqt5opengl5-dev libqt5serialport5-dev libqt5sql5-sqlite libqt5svg5-dev \
    libqt5webkit5-dev libqt5xmlpatterns5-dev libqwt-qt5-dev libspatialindex-dev \
    libspatialite-dev libsqlite3-dev libsqlite3-mod-spatialite libyaml-tiny-perl \
    libzip-dev libzstd-dev lighttpd locales ninja-build ocl-icd-opencl-dev \
    opencl-headers pandoc pdal pkg-config poppler-utils protobuf-compiler \
    pyqt5-dev pyqt5-dev-tools pyqt5.qsci-dev python3-all-dev python3-autopep8 \
    python3-dev python3-gdal python3-jinja2 python3-lxml python3-mock \
    python3-nose2 python3-owslib python3-plotly python3-psycopg2 python3-pygments \
    python3-pyproj python3-pyqt5 python3-pyqt5.qsci python3-pyqt5.qtmultimedia \
    python3-pyqt5.qtpositioning python3-pyqt5.qtserialport python3-pyqt5.qtsql \
    python3-pyqt5.qtsvg python3-pyqt5.qtwebkit python3-pyqtbuild python3-sip \
    python3-termcolor python3-yaml qt3d-assimpsceneimport-plugin \
    qt3d-defaultgeometryloader-plugin qt3d-gltfsceneio-plugin qt3d-scene2d-plugin \
    qt3d5-dev qtbase5-dev qtbase5-private-dev qtkeychain-qt5-dev qtmultimedia5-dev \
    qtpositioning5-dev qttools5-dev qttools5-dev-tools sip-tools spawn-fcgi xauth \
    xfonts-100dpi xfonts-75dpi xfonts-base xfonts-scalable xvfb

RUN apt -y install nodejs

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt -y install yarn
ENV PATH /usr/lib/ccache:$PATH
RUN mkdir -p /opt/qgis && \
    mkdir -p $HOME/dev/cpp && cd $HOME/dev/cpp && git clone https://github.com/qgis/QGIS.git \
    && cd QGIS && mkdir build-master && cd build-master && pwd && \
    cmake -D CMAKE_BUILD_TYPE=Debug -D CMAKE_INSTALL_PREFIX=/opt/qgis  ..

#RUN cd $HOME/apps/bin && ls -l

ENV PATH /opt/qgis/bin:$PATH

#RUN mkdir -p /home/${USER}/apps
#ENV PATH /home/${USER}/apps:$PATH

#RUN cmake -D CMAKE_INSTALL_PREFIX=$HOME/apps -D CMAKE_BUILD_TYPE=Debug ..
#RUN make install

#RUN cd /home/${USER}/apps/bin

#RUN mkdir -p /etc/apt/sources.list.d/
#ADD qgis.sources /etc/apt/sources.list.d/

#RUN mkdir -m755 -p /etc/apt/keyrings  # not needed since apt version 2.4.0 like Debian 12 and Ubuntu 22 or newer
#RUN wget -O /etc/apt/keyrings/qgis-archive-keyring.gpg https://download.qgis.org/downloads/qgis-archive-keyring.gpg

#RUN apt -y update
#RUN apt install -y qgis qgis-plugin-grass qgis-server

COPY --from=taccaci/interactive-base:1.1.0 /tapis /tapis

ENTRYPOINT [ "/tapis/run.sh"]