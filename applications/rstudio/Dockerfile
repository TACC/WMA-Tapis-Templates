### install rstudio ###
FROM rocker/rstudio:latest

RUN mkdir /var/run/s6

COPY --from=taccaci/interactive-base:1.1.0 /tapis /tapis

ENTRYPOINT ["/tapis/run.sh"]