FROM debian:bookworm-slim

COPY run.sh /tapis/run.sh

RUN chmod +x /tapis/run.sh

ENTRYPOINT [ "/tapis/run.sh" ]

CMD ["1280x800"]
