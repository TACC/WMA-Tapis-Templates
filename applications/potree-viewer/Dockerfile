FROM nginx

RUN useradd --create-home --shell /bin/bash potree

RUN mkdir /data
RUN chown potree /data



RUN chown -R potree /etc/nginx/ & \
    chmod u=rwx /etc/nginx/

COPY ./default.template /etc/nginx/conf.d/default.template
COPY ./nginx.conf /etc/nginx/nginx.conf

RUN touch /var/run/nginx.pid && \
  chown -R potree /var/run/nginx.pid && \
  chown -R potree /var/cache/nginx

USER potree
VOLUME /data