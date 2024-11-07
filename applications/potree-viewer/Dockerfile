FROM nginx:stable

RUN apt-get update && apt-get install -y apache2-utils && \
    mkdir /data

COPY ./default.template /etc/nginx/conf.d/default.template

VOLUME /data
