### use pyreconstruct image ###
FROM tiffhuff/pyreconstruct:0.0.1
# File copy is needed to avoid these from getting overwritten by bind mounts.
# Bind mounts are needed for setting up interactive session (tools like dcv)
RUN cp /lib/x86_64-linux-gnu/libm.so.6 /usr/local/bin/../lib/libm.so.6 && \
  cp /lib/x86_64-linux-gnu/libpthread.so.0 /usr/local/bin/../lib/libpthread.so.0  && \
  cp /lib/x86_64-linux-gnu/libc.so.6 /usr/local/bin/../lib/libc.so.6 && \
  cp /lib/x86_64-linux-gnu/libdl.so.2 /usr/local/bin/../lib/libdl.so.2 && \
  cp /lib/x86_64-linux-gnu/libutil.so.1 /usr/local/bin/../lib/libutil.so.1 && \
  cp /lib64/ld-linux-x86-64.so.2 /usr/local/bin/../lib/ld-linux-x86-64.so.2 && \
  cp /lib/x86_64-linux-gnu/librt.so.1 /usr/local/bin/../lib/librt.so.1 && \
  cp /lib/x86_64-linux-gnu/libbz2.so.1.0 /usr/local/bin/../lib/libbz2.so.1.0

COPY --from=taccaci/interactive-base:1.1.0 /tapis /tapis
COPY wrapper.sh /app/wrapper.sh
RUN chmod +x /app/wrapper.sh

ENTRYPOINT [ "/tapis/run.sh" ]

CMD ["1280x800"]