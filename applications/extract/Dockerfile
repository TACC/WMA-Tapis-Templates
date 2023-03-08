FROM debian:stable-slim

RUN apt-get update && apt-get install -y \
    zip \
    && rm -rf /var/lib/apt/lists/*

COPY run.sh /tapis/run.sh

RUN chmod +x /tapis/run.sh

ENV PATH="/tapis:${PATH}"

ENTRYPOINT [ "run.sh" ]
