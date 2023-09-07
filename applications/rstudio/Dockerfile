### install rstudio ###
FROM rocker/rstudio:4.3

COPY --from=taccaci/interactive-base:1.1.0 /tapis /tapis

ENTRYPOINT ["/tapis/run.sh"]
