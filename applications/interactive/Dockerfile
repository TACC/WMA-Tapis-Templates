FROM debian:bullseye-slim

COPY run.sh /singularity/run.sh

RUN chmod +x /singularity/run.sh

ENTRYPOINT [ "/singularity/run.sh" ]

CMD ["1280x800"]
