FROM debian:bookworm-slim

ENV LANG=en_EN.UTF-8


RUN apt-get update \
    && apt-get install --no-install-recommends --no-install-suggests --allow-unauthenticated -y \
        gnupg \
        ca-certificates \
        wget \
        locales \
    && localedef -i en_US -f UTF-8 en_US.UTF-8 \
    # Add the current key for package downloading
    # Please refer to QGIS install documentation (https://www.qgis.org/fr/site/forusers/alldownloads.html#debian-ubuntu)
    && mkdir -m755 -p /etc/apt/keyrings \
    && wget -O /etc/apt/keyrings/qgis-archive-keyring.gpg https://download.qgis.org/downloads/qgis-archive-keyring.gpg \
    # Add repository for latest version of qgis-server
    # Please refer to QGIS repositories documentation if you want other version (https://qgis.org/en/site/forusers/alldownloads.html#repositories)
    && echo "deb [signed-by=/etc/apt/keyrings/qgis-archive-keyring.gpg] https://qgis.org/debian bookworm main" | tee /etc/apt/sources.list.d/qgis.list \
    && apt-get update \
    && apt-get install --no-install-recommends --no-install-suggests --allow-unauthenticated -y \
        qgis-server \
        spawn-fcgi \
        xauth \
        xvfb \
    && apt-get remove --purge -y \
        gnupg \
        wget \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m qgis

ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

ENV QGIS_PREFIX_PATH /usr
ENV QGIS_SERVER_LOG_STDERR 1
ENV QGIS_SERVER_LOG_LEVEL 2

COPY cmd.sh /home/qgis/cmd.sh
RUN chmod -R 777 /home/qgis/cmd.sh
RUN chown qgis:qgis /home/qgis/cmd.sh

USER qgis
WORKDIR /home/qgis

ENTRYPOINT ["/tini", "--"]

CMD ["/home/qgis/cmd.sh"]