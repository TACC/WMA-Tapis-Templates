### pyreconstruct dev image matching PyReconsturct-dev app ###
FROM eriksf/pyreconstruct:latest

COPY --from=taccaci/interactive-base:1.1.0 /tapis /tapis

ENTRYPOINT [ "/tapis/run.sh" ]

CMD ["1280x800"]