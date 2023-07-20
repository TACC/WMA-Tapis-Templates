FROM eriksf/fiji:openjdk-8-ui

COPY --from=taccaci/interactive-base:1.1.0 /tapis /tapis

ENTRYPOINT [ "/tapis/run.sh" ]
