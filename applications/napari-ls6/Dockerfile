FROM eriksf/napari:latest

COPY --from=taccaci/interactive-base:1.1.0 /tapis /tapis

ENTRYPOINT [ "/tapis/run.sh"]