### pyreconstruct dev image matching PyReconsturct-dev app ###
FROM eriksf/pyreconstruct:latest

COPY run.sh /tapis/run.sh
RUN chmod +x /tapis/run.sh

ENTRYPOINT [ "/tapis/run.sh" ]

CMD ["1280x800"]
