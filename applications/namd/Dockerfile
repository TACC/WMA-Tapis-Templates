# From TACC containers: https://github.com/TACC/tacc-containers
FROM tacc/tacc-centos7-impi19.0.7-common:latest
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

RUN yum install -y centos-release-scl
RUN yum install -y devtoolset-8

COPY run.sh /tapis/run.sh
RUN chmod +x /tapis/run.sh

ENTRYPOINT [ "/tapis/run.sh" ]
