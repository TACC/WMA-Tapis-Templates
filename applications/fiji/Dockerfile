FROM jlabyer/fiji-openjdk-8-ui:1.0.0

# This softlink is necessary because the normal config file location is not editable because Tapis
# containers are read-only. Some variables in the config file must be updated with parameters from the job,
# so they must be updated within the container. Linking the normal config location to a file in /tmp/
# allows the file in /tmp/ to be updated by run.sh with the job parameters.

RUN ln -s /tmp/ImageJ.cfg /opt/fiji/Fiji.app/ImageJ.cfg

COPY run.sh /tapis/run.sh

RUN chmod +x /tapis/run.sh

ENTRYPOINT [ "/tapis/run.sh" ]

CMD [ "1280x800" ]