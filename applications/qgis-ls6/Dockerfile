FROM ubuntu:20.04

ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

RUN echo "tzdata tzdata/Areas select America" >> preseed.txt
RUN echo "tzdata tzdata/Zones/America select Chicago" >> preseed.txt
RUN debconf-set-selections preseed.txt

RUN apt -y update && apt -y upgrade

RUN apt install -y gnupg software-properties-common wget

RUN mkdir -p /etc/apt/sources.list.d/
ADD qgis.sources /etc/apt/sources.list.d/

RUN mkdir -m755 -p /etc/apt/keyrings  # not needed since apt version 2.4.0 like Debian 12 and Ubuntu 22 or newer
RUN wget -O /etc/apt/keyrings/qgis-archive-keyring.gpg https://download.qgis.org/downloads/qgis-archive-keyring.gpg

RUN apt -y update
RUN apt install -y qgis qgis-plugin-grass qgis-server

COPY --from=taccaci/interactive-base:1.1.0 /tapis /tapis

ENTRYPOINT [ "/tapis/run.sh"]

CMD ["1280x800"]